#     Copyright 2025. ThingsBoard
#
#     Licensed under the Apache License, Version 2.0 (the "License");
#     you may not use this file except in compliance with the License.
#     You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.

import asyncio
from json import dumps
from queue import Queue
from random import choice
from string import ascii_lowercase
from threading import Thread
from time import sleep

from thingsboard_gateway.connectors.connector import Connector
from thingsboard_gateway.connectors.xmpp.device import Device
from thingsboard_gateway.gateway.entities.converted_data import ConvertedData
from thingsboard_gateway.gateway.statistics.decorators import CollectStatistics, CollectAllReceivedBytesStatistics
from thingsboard_gateway.tb_utility.tb_loader import TBModuleLoader
from thingsboard_gateway.tb_utility.tb_utility import TBUtility
from thingsboard_gateway.gateway.statistics.statistics_service import StatisticsService
from thingsboard_gateway.tb_utility.tb_logger import init_logger

try:
    from slixmpp import ClientXMPP
except ImportError:
    print("Slixmpp library not found - installing...")
    TBUtility.install_package("slixmpp")
    from slixmpp import ClientXMPP

from slixmpp.exceptions import IqError, IqTimeout

DEFAULT_UPLINK_CONVERTER = 'XmppUplinkConverter'


class XMPPConnector(Connector, Thread):
    INCOMING_MESSAGES = Queue()
    DATA_TO_SEND = Queue()

    def __init__(self, gateway, config, connector_type):
        self.statistics = {'MessagesReceived': 0,
                           'MessagesSent': 0}

        super().__init__()

        self._connector_type = connector_type
        self.__gateway = gateway

        self.__config = config
        self.__id = self.__config.get('id')
        self._server_config = config['server']
        self._devices_config = config.get('devices', [])
        self.name = config.get("name", 'XMPP Connector ' + ''.join(choice(ascii_lowercase) for _ in range(5)))
        self.__log = init_logger(self.__gateway, self.name, self.__config.get('logLevel', 'INFO'),
                                 enable_remote_logging=self.__config.get('enableRemoteLogging', False),
                                 is_connector_logger=True)
        self.__converter_log = init_logger(self.__gateway, self.name + '_converter',
                                           self.__config.get('logLevel', 'INFO'),
                                           enable_remote_logging=self.__config.get('enableRemoteLogging', False),
                                           is_connector_logger=True, attr_name=self.name)

        self._devices = {}
        self._reformat_devices_config()

        # devices dict for RPC and attributes updates
        # {'deviceName': 'device_jid'}
        self._available_device = {}

        self.__stopped = False
        self._connected = False
        self.daemon = True

        self._xmpp = None

    def _reformat_devices_config(self):
        for config in self._devices_config:
            try:
                device_jid = config.get('jid')

                converter_name = config.pop('converter', DEFAULT_UPLINK_CONVERTER)
                converter = self._load_converter(converter_name)
                if not converter:
                    continue

                self._devices[device_jid] = Device(
                    jid=device_jid,
                    device_name_expression=config['deviceNameExpression'],
                    device_type_expression=config['deviceTypeExpression'],
                    attributes=config.get('attributes', []),
                    timeseries=config.get('timeseries', []),
                    attribute_updates=config.get('attributeUpdates', []),
                    server_side_rpc=config.get('serverSideRpc', [])
                )
                self._devices[device_jid].set_converter(converter(config, self.__converter_log))
            except KeyError as e:
                self.__log.error('Invalid configuration %s with key error %s', config, e)
                continue

    def _load_converter(self, converter_name):
        module = TBModuleLoader.import_module(self._connector_type, converter_name)

        if module:
            self.__log.debug('Converter %s for device %s - found!', converter_name, self.name)
            return module

        self.__log.error("Cannot find converter for %s device", self.name)
        return None

    def open(self):
        self.__stopped = False
        self.start()
        self.__log.info('Starting XMPP Connector')

    def run(self):
        process_messages_thread = Thread(target=self._process_messages,
                                         name='Validate incoming msgs thread', daemon=True)
        process_messages_thread.start()

        data_to_send_thread = Thread(target=self._send_data, name='Data to send thread', daemon=True)
        data_to_send_thread.start()

        self.create_client()

    def create_client(self):
        # creating event loop for slixmpp
        asyncio.set_event_loop(asyncio.new_event_loop())

        self.__log.info('Starting XMPP Client...')
        self._xmpp = ClientXMPP(jid=self._server_config['jid'], password=self._server_config['password'])

        self._xmpp.add_event_handler("session_start", self.session_start)
        self._xmpp.add_event_handler("message", self.message)
        self._xmpp['feature_mechanisms'].unencrypted_plain = self._server_config.get('unencrypted_plain_auth', True)

        for plugin in self._server_config.get('plugins', []):
            self._xmpp.register_plugin(plugin)

        self._xmpp.connect(address=(self._server_config['host'], self._server_config['port']),
                           use_ssl=self._server_config.get('use_ssl', False),
                           disable_starttls=self._server_config.get('disable_starttls', False),
                           force_starttls=self._server_config.get('force_starttls', True))
        self._xmpp.process(forever=True, timeout=self._server_config.get('timeout', 10000))

    def session_start(self, _):
        try:
            self._xmpp.send_presence()
            self._xmpp.get_roster()
        except IqError as err:
            self.__log.error('There was an error getting the roster')
            self.__log.error(err.iq['error']['condition'])
            self._xmpp.disconnect()
            self.close()
        except IqTimeout:
            self.__log.error('Server is taking too long to respond')
            self._xmpp.disconnect()
            self.close()

        self._connected = True

    @staticmethod
    def message(msg):
        # put incoming messages to the queue because of data missing probability
        XMPPConnector.INCOMING_MESSAGES.put(msg)

    def _process_messages(self):
        while not self.__stopped:
            if not XMPPConnector.INCOMING_MESSAGES.empty():
                msg = XMPPConnector.INCOMING_MESSAGES.get()
                self.__log.debug('Got message: %s', msg.values)

                try:
                    device_jid = msg.values['from']
                    device = self._devices.get(device_jid)
                    if device:
                        StatisticsService.count_connector_message(self.name,
                                                                  stat_parameter_name='connectorMsgsReceived')
                        StatisticsService.count_connector_bytes(self.name, msg.values['body'],
                                                                stat_parameter_name='connectorBytesReceived')

                        converted_data = device.converter.convert(device, msg.values['body'])

                        if converted_data:
                            XMPPConnector.DATA_TO_SEND.put(converted_data)

                            if not self._available_device.get(converted_data.device_name):
                                self._available_device[converted_data.device_name] = device_jid
                        else:
                            self.__log.error('Converted data is empty')
                    else:
                        self.__log.info('Device %s not found', device_jid)
                except KeyError as e:
                    self.__log.exception(e)

            sleep(.2)

    def _send_data(self):
        while not self.__stopped:
            if not XMPPConnector.DATA_TO_SEND.empty():
                data: ConvertedData = XMPPConnector.DATA_TO_SEND.get()
                if data.attributes_datapoints_count > 0 or data.telemetry_datapoints_count > 0:
                    self.statistics['MessagesReceived'] = self.statistics['MessagesReceived'] + 1
                    self.__gateway.send_to_storage(self.get_name(), self.get_id(), data)
                    self.statistics['MessagesSent'] = self.statistics['MessagesSent'] + 1
                    self.__log.info('Data to ThingsBoard %s', data)

            sleep(.2)

    def close(self):
        self.__stopped = True
        self._connected = False
        self.__log.info('%s has been stopped.', self.get_name())
        self.__log.stop()

    def get_id(self):
        return self.__id

    def get_name(self):
        return self.name

    def get_type(self):
        return self._connector_type

    def is_connected(self):
        return self._connected

    def is_stopped(self):
        return self.__stopped

    def get_config(self):
        return self.__config

    @CollectStatistics(start_stat_type='allBytesSentToDevices')
    def _send_message(self, jid, data):
        self._xmpp.send_message(mto=jid, mfrom=self._server_config['jid'], mbody=data,
                                mtype='chat')

    @CollectAllReceivedBytesStatistics(start_stat_type='allReceivedBytesFromTB')
    def on_attributes_update(self, content):
        self.__log.debug('Got attribute update: %s', content)

        try:
            device_jid = self._available_device.get(content['device'])
            if not device_jid:
                self.__log.error('Device not found')

            attr_updates = self._devices[device_jid].attribute_updates
            for key, value in content['data'].items():
                for attr_conf in attr_updates:
                    if attr_conf['attributeOnThingsBoard'] == key:
                        data_to_send = attr_conf['valueExpression'].replace('${attributeKey}', key).replace(
                            '${attributeValue}', value)
                        self._send_message(device_jid, data_to_send)
                        return
        except KeyError as e:
            self.__log.error('Key not found %s during processing attribute update', e)

    @CollectAllReceivedBytesStatistics(start_stat_type='allReceivedBytesFromTB')
    def server_side_rpc_handler(self, content):
        self.__log.debug('Got RPC: %s', content)

        try:
            if self.__is_reserved_rpc(content):
                self.__process_reserved_rpc(content)
                return

            device_jid = self._available_device.get(content['device'])
            if not device_jid:
                self.__log.error('Device not found')

            rpcs = self._devices[device_jid].server_side_rpc
            for rpc_conf in rpcs:
                if rpc_conf['methodRPC'] == content['data']['method']:
                    data_to_send_tags = TBUtility.get_values(rpc_conf.get('valueExpression'), content['data'],
                                                             'params',
                                                             get_tag=True)
                    data_to_send_values = TBUtility.get_values(rpc_conf.get('valueExpression'), content['data'],
                                                               'params',
                                                               expression_instead_none=True)

                    data_to_send = rpc_conf.get('valueExpression')
                    for (tag, value) in zip(data_to_send_tags, data_to_send_values):
                        data_to_send = data_to_send.replace('${' + tag + '}', dumps(value))

                    self._send_message(device_jid, data_to_send)

                    if rpc_conf.get('withResponse', True):
                        self.__gateway.send_rpc_reply(device=content["device"], req_id=content["data"]["id"],
                                                      success_sent=True)

                        return
        except KeyError as e:
            self.__log.error('Key not found %s during processing rpc', e)

    def __is_reserved_rpc(self, rpc) -> bool:
        rpc_method_name = rpc.get('data', {}).get('method')

        if rpc_method_name == 'set':
            return True

        return False

    def __process_reserved_rpc(self, rpc):
        params = self.__get_reserved_rpc_params(rpc)
        if not params:
            self.__log.error('RPC params are empty, expected format: set value={value};')
            self.__gateway.send_rpc_reply(device=rpc['device'],
                                          req_id=rpc['data']['id'],
                                          content={
                                              rpc['data']['method']:
                                                  'RPC params are empty, expected format: set value={value};'
                                          })
            return

        device_jid = self._available_device.get(rpc['device'])
        if not device_jid:
            self.__log.error('Device not found')
            return

        try:
            self._send_message(device_jid, dumps(params))
            self.__gateway.send_rpc_reply(device=rpc['device'],
                                          req_id=rpc['data']['id'],
                                          content={'result': {"success": True}})
        except Exception as e:
            self.__log.error('Error during sending reserved RPC %s', e)
            self.__gateway.send_rpc_reply(device=rpc['device'],
                                          req_id=rpc['data']['id'],
                                          content={rpc['data']['method']: 'Error during sending reserved RPC %s' % e})

    def __get_reserved_rpc_params(self, rpc):
        params = {}

        rpc_params = rpc.get('data', {}).get('params')
        if rpc_params is None:
            return {}

        for param in rpc_params.split(';'):
            try:
                (key, value) = param.split('=')
            except ValueError:
                continue

            if key and value:
                params[key] = value

        return params
