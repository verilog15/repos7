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

from time import time
from hashlib import sha1
from os import path
from pathlib import Path
from random import choice
from string import ascii_lowercase
from threading import Thread
from time import sleep

from simplejson import dumps, load

from thingsboard_gateway.gateway.constants import TELEMETRY_PARAMETER
from thingsboard_gateway.gateway.entities.converted_data import ConvertedData
from thingsboard_gateway.gateway.statistics.decorators import CollectAllReceivedBytesStatistics
from thingsboard_gateway.tb_utility.tb_loader import TBModuleLoader
from thingsboard_gateway.tb_utility.tb_utility import TBUtility
from thingsboard_gateway.tb_utility.tb_logger import init_logger
from thingsboard_gateway.gateway.statistics.statistics_service import StatisticsService

try:
    import pyodbc
except ImportError:
    print("ODBC library not found - installing...")
    TBUtility.install_package("pyodbc")
    import pyodbc

from thingsboard_gateway.connectors.odbc.odbc_uplink_converter import OdbcUplinkConverter

from thingsboard_gateway.connectors.connector import Connector


class OdbcConnector(Connector, Thread):
    DEFAULT_RECONNECT_STATE = True
    DEFAULT_SAVE_ITERATOR = False
    DEFAULT_RECONNECT_PERIOD = 60
    DEFAULT_POLL_PERIOD = 60
    DEFAULT_ENABLE_UNKNOWN_RPC = False
    DEFAULT_OVERRIDE_RPC_PARAMS = False
    DEFAULT_PROCESS_RPC_RESULT = False

    def __init__(self, gateway, config, connector_type):
        super().__init__()
        self.daemon = True
        self.name = config.get("name", 'ODBC Connector ' + ''.join(choice(ascii_lowercase) for _ in range(5)))

        self.statistics = {'MessagesReceived': 0,
                           'MessagesSent': 0}
        self.__gateway = gateway
        self.__config = config
        self.__id = self.__config.get('id')
        self._log = init_logger(self.__gateway, self.name, self.__config.get('logLevel', 'INFO'),
                                enable_remote_logging=self.__config.get('enableRemoteLogging', False),
                                is_connector_logger=True)
        self._converter_log = init_logger(self.__gateway, self.name + '_converter',
                                          self.__config.get('logLevel', 'INFO'),
                                          enable_remote_logging=self.__config.get('enableRemoteLogging', False),
                                          is_converter_logger=True, attr_name=self.name)
        self._connector_type = connector_type
        self.__stopped = False

        self.__config_dir = self.__gateway.get_config_path() + "odbc" + path.sep

        self.__connection = None
        self.__cursor = None
        self.__rpc_cursor = None
        self.__iterator = None
        self.__iterator_file_name = ""

        self.__devices = {}

        self.__column_names = []
        self.__attribute_columns = []
        self.__timeseries_columns = []

        self.__converter = OdbcUplinkConverter(self._converter_log) if not self.__config.get("converter", "") else \
            TBModuleLoader.import_module(self._connector_type, self.__config["converter"])

        self.__configure_pyodbc()
        self.__parse_rpc_config()

    def open(self):
        self._log.debug("[%s] Starting...", self.get_name())
        self.__stopped = False
        self.start()

    def close(self):
        if not self.__stopped:
            self.__stopped = True
            self._log.debug("[%s] Stopping", self.get_name())
            self._log.stop()

    def get_id(self):
        return self.__id

    def get_name(self):
        return self.name

    def get_type(self):
        return self._connector_type

    def is_connected(self):
        return self.__connection is not None

    def is_stopped(self):
        return self.__stopped

    def on_attributes_update(self, content):
        pass

    @CollectAllReceivedBytesStatistics(start_stat_type='allReceivedBytesFromTB')
    def server_side_rpc_handler(self, content):
        done = False
        try:
            if not self.is_connected():
                self._log.warning("[%s] Cannot process RPC request: not connected to database", self.get_name())
                raise Exception("no connection")

            if self.__is_reserved_rpc(content):
                self.__process_reverved_rpc(content)
                return

            is_rpc_unknown = False
            rpc_config = self.__config["serverSideRpc"]["methods"].get(content["data"]["method"])
            if rpc_config is None:
                if not self.__config["serverSideRpc"]["enableUnknownRpc"]:
                    self._log.warning("[%s] Ignore unknown RPC request '%s' (id=%s)",
                                      self.get_name(), content["data"]["method"], content["data"]["id"])
                    raise Exception("unknown RPC request")
                else:
                    is_rpc_unknown = True
                    rpc_config = content["data"].get("params", {})
                    sql_params = rpc_config.get("args", [])
                    query = rpc_config.get("query", "")
            else:
                if self.__config["serverSideRpc"]["overrideRpcConfig"]:
                    rpc_config = {**rpc_config, **content["data"].get("params", {})}

                # The params attribute is obsolete but leave for backward configuration compatibility
                sql_params = rpc_config.get("args") or rpc_config.get("params", [])
                query = rpc_config.get("query", "")

            self._log.debug("[%s] Processing %s '%s' RPC request (id=%s) for '%s' device: params=%s, query=%s",
                            self.get_name(), "unknown" if is_rpc_unknown else "", content["data"]["method"],
                            content["data"]["id"], content["device"], sql_params, query)

            self.__process_rpc(content["data"]["method"], query, sql_params)

            done = True
            self._log.debug("[%s] Processed '%s' RPC request (id=%s) for '%s' device",
                            self.get_name(), content["data"]["method"], content["data"]["id"], content["device"])
        except pyodbc.Warning as w:
            self._log.warning("[%s] Warning while processing '%s' RPC request (id=%s) for '%s' device: %s",
                              self.get_name(), content["data"]["method"], content["data"]["id"], content["device"],
                              str(w))
        except Exception as e:
            self._log.error("[%s] Failed to process '%s' RPC request (id=%s) for '%s' device: %s",
                            self.get_name(), content["data"]["method"], content["data"]["id"], content["device"],
                            str(e))
        finally:
            if done and rpc_config.get("result", self.DEFAULT_PROCESS_RPC_RESULT):
                response = self.row_to_dict(self.__rpc_cursor.fetchone())
                self.__gateway.send_rpc_reply(content["device"], content["data"]["id"], response)
            else:
                self.__gateway.send_rpc_reply(content["device"], content["data"]["id"], {"success": done})

    def __is_reserved_rpc(self, rpc):
        rpc_method_name = rpc.get('data', {}).get('method')

        if rpc_method_name == 'set' or rpc_method_name == 'get':
            return True

        return False

    def __process_reverved_rpc(self, rpc):
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

        sql_params = params.get('value', [])
        query = params.get('query', '')
        procedure_name = params.get('procedure_name', '')
        with_result = params.get('with_result', False)

        try:
            self.__process_rpc(procedure_name, query, sql_params)
        except pyodbc.Warning as w:
            self._log.warning("[%s] Warning while processing '%s' RPC request (id=%s) for '%s' device: %s",
                              self.get_name(), rpc["data"]["method"], rpc["data"]["id"], rpc["device"],
                              str(w))
        except Exception as e:
            self._log.error("[%s] Failed to process '%s' RPC request (id=%s) for '%s' device: %s",
                            self.get_name(), rpc["data"]["method"], rpc["data"]["id"], rpc["device"],
                            str(e))
            self.__gateway.send_rpc_reply(device=rpc['device'],
                                          req_id=rpc['data']['id'],
                                          content={rpc['data']['method']: 'Error during executing reserved RPC %s' % e})
            return

        if with_result:
            response = self.row_to_dict(self.__rpc_cursor.fetchone())
            self.__gateway.send_rpc_reply(device=rpc["device"],
                                          req_id=rpc["data"]["id"],
                                          content={'result': response})
        else:
            self.__gateway.send_rpc_reply(device=rpc["device"],
                                          req_id=rpc["data"]["id"],
                                          content={'result': {"success": True}})

    def __get_reserved_rpc_params(self, rpc):
        params = {}

        rpc_params = rpc.get('data', {}).get('params')
        if rpc_params is None:
            return {}

        try:
            for param in rpc_params.split(';'):
                try:
                    (key, value) = param.split('=')
                except ValueError:
                    continue

                if key and value:
                    if key == 'with_result':
                        params[key] = value.lower() == 'true'
                    elif key == 'value':
                        params[key] = value.split(',')
                    else:
                        params[key] = value
        except Exception as e:
            self.__log.error('Error during parsing RPC params: %s', e)
            return {}

        return params

    def __process_rpc(self, procedure_name, query, sql_params):
        if self.__rpc_cursor is None:
            self.__rpc_cursor = self.__connection.cursor()

        if query:
            if sql_params:
                self.__rpc_cursor.execute(query, sql_params)
            else:
                self.__rpc_cursor.execute(query)
        else:
            if sql_params:
                query_to_execute = "{{CALL {} ({})}}".format(procedure_name, ("?," * len(sql_params))[0:-1])
                self.__rpc_cursor.execute(query_to_execute, sql_params)
            else:
                self.__rpc_cursor.execute("{{CALL {}}}".format(procedure_name))

    def run(self):
        while not self.__stopped:
            # Initialization phase
            if not self.is_connected():
                while not self.__stopped and \
                        not self.__init_connection() and \
                        self.__config["connection"].get("reconnect", self.DEFAULT_RECONNECT_STATE):
                    reconnect_period = self.__config["connection"].get("reconnectPeriod", self.DEFAULT_RECONNECT_PERIOD)
                    self._log.info("[%s] Will reconnect to database in %d second(s)", self.get_name(), reconnect_period)
                    sleep(reconnect_period)

                if not self.is_connected():
                    self._log.error("[%s] Cannot connect to database so exit from main loop", self.get_name())
                    break

                if not self.__init_iterator():
                    self._log.error("[%s] Cannot init database iterator so exit from main loop", self.get_name())
                    break

            # Polling phase
            try:
                self.__poll()
                if not self.__stopped:
                    polling_period = self.__config["polling"].get("period", self.DEFAULT_POLL_PERIOD)
                    self._log.debug("[%s] Next polling iteration will be in %d second(s)", self.get_name(), polling_period)
                    sleep(polling_period)
            except pyodbc.Warning as w:
                self._log.warning("[%s] Warning while polling database: %s", self.get_name(), str(w))
            except pyodbc.Error as e:
                self._log.error("[%s] Error while polling database: %s", self.get_name(), str(e))
                self.__close()

        self.__close()
        self.__stopped = False
        self._log.info("[%s] Stopped", self.get_name())

    def __close(self):
        if self.is_connected():
            try:
                self.__cursor.close()
                if self.__rpc_cursor is not None:
                    self.__rpc_cursor.close()
                self.__connection.close()
            finally:
                self._log.info("[%s] Connection to database closed", self.get_name())
                self.__connection = None
                self.__cursor = None
                self.__rpc_cursor = None

    def __poll(self):
        rows = self.__cursor.execute(self.__config["polling"]["query"], self.__iterator["value"])

        if not self.__column_names:
            for column in self.__cursor.description:
                self.__column_names.append(column[0])
            self._log.info("[%s] Fetch column names: %s", self.get_name(), self.__column_names)

        # For some reason pyodbc.Cursor.rowcount may be 0 (sqlite) so use our own row counter
        row_count = 0
        for row in rows:
            self._log.debug("[%s] Fetch row: %s", self.get_name(), row)
            StatisticsService.count_connector_message(self.name, stat_parameter_name='connectorMsgsReceived')
            StatisticsService.count_connector_bytes(self.name, row,
                                                    stat_parameter_name='connectorBytesReceived')

            self.__process_row(row)
            row_count += 1

        self.__iterator["total"] += row_count
        self._log.info("[%s] Polling iteration finished. Processed rows: current %d, total %d",
                       self.get_name(), row_count, self.__iterator["total"])

        if self.__config["polling"]["iterator"]["persistent"] and row_count > 0:
            self.__save_iterator_config()

    def __process_row(self, row):
        try:
            data = self.row_to_dict(row)

            converted_data: ConvertedData = self.__converter.convert(self.__config["mapping"], data)

            StatisticsService.count_connector_message(self._log.name, 'convertersAttrProduced',
                                                      count=converted_data.attributes_datapoints_count)
            StatisticsService.count_connector_message(self._log.name, 'convertersTsProduced',
                                                      count=converted_data.telemetry_datapoints_count)

            converted_data.device_name = eval(self.__config["mapping"]["device"]["name"], globals(), data)

            device_type = eval(self.__config["mapping"]["device"]["type"], globals(), data)
            if not device_type:
                device_type = self.__config["mapping"]["device"].get("type", "default")
            converted_data.device_type = device_type

            if converted_data.telemetry_datapoints_count + converted_data.attributes_datapoints_count > 0:
                self.__iterator["value"] = getattr(row, self.__iterator["name"])
                self.__check_and_send(converted_data)
        except Exception as e:
            self._log.warning("[%s] Failed to process database row: %s", self.get_name(), str(e))

    @staticmethod
    def row_to_dict(row):
        data = {}
        for column_description in row.cursor_description:
            data[column_description[0]] = getattr(row, column_description[0])
        return data

    def __check_and_send(self, to_send: ConvertedData):
        self.statistics['MessagesReceived'] += 1

        if to_send.attributes_datapoints_count + to_send.telemetry_datapoints_count > 0:
            self._log.debug("[%s] Converted data for device '%s': %s", self.get_name(), to_send.device_name, to_send)
            self.__gateway.send_to_storage(self.get_name(), self.get_id(), to_send)
            self.statistics['MessagesSent'] += 1

    def __init_connection(self):
        try:
            self._log.debug("[%s] Opening connection to database", self.get_name())
            connection_config = self.__config["connection"]
            self.__connection = pyodbc.connect(connection_config["str"], **connection_config.get("attributes", {}))
            if connection_config.get("encoding", ""):
                self._log.info("[%s] Setting encoding to %s", self.get_name(), connection_config["encoding"])
                self.__connection.setencoding(connection_config["encoding"])

            decoding_config = connection_config.get("decoding")
            if decoding_config is not None:
                if isinstance(decoding_config, dict):
                    if decoding_config.get("char", ""):
                        self._log.info("[%s] Setting SQL_CHAR decoding to %s", self.get_name(), decoding_config["char"])
                        self.__connection.setdecoding(pyodbc.SQL_CHAR, decoding_config["char"])
                    if decoding_config.get("wchar", ""):
                        self._log.info("[%s] Setting SQL_WCHAR decoding to %s", self.get_name(),
                                       decoding_config["wchar"])
                        self.__connection.setdecoding(pyodbc.SQL_WCHAR, decoding_config["wchar"])
                    if decoding_config.get("metadata", ""):
                        self._log.info("[%s] Setting SQL_WMETADATA decoding to %s",
                                       self.get_name(), decoding_config["metadata"])
                        self.__connection.setdecoding(pyodbc.SQL_WMETADATA, decoding_config["metadata"])
                else:
                    self._log.warning("[%s] Unknown decoding configuration %s. Read data may be misdecoded",
                                      self.get_name(),
                                      decoding_config)

            self.__cursor = self.__connection.cursor()
            self._log.info("[%s] Connection to database opened, attributes %s",
                           self.get_name(), connection_config.get("attributes", {}))
        except pyodbc.Error as e:
            self._log.error("[%s] Failed to connect to database: %s", self.get_name(), str(e))
            self.__close()

        return self.is_connected()

    def __resolve_iterator_file(self):
        file_name = ""
        try:
            # The algorithm of resolving iterator file name is described in
            # https://thingsboard.io/docs/iot-gateway/config/odbc/#subsection-iterator
            # Edit that description whether algorithm is changed.
            file_name += self.__connection.getinfo(pyodbc.SQL_DRIVER_NAME)
            file_name += self.__connection.getinfo(pyodbc.SQL_SERVER_NAME)
            file_name += self.__connection.getinfo(pyodbc.SQL_DATABASE_NAME)
            file_name += self.get_name()
            file_name += self.__config["polling"]["iterator"]["column"]

            self.__iterator_file_name = sha1(file_name.encode()).hexdigest() + ".json"
            self._log.debug("[%s] Iterator file name resolved to %s", self.get_name(), self.__iterator_file_name)
        except Exception as e:
            self._log.warning("[%s] Failed to resolve iterator file name: %s", self.get_name(), str(e))
        return bool(self.__iterator_file_name)

    def __init_iterator(self):
        save_iterator = self.DEFAULT_SAVE_ITERATOR
        if "persistent" not in self.__config["polling"]["iterator"]:
            self.__config["polling"]["iterator"]["persistent"] = save_iterator
        else:
            save_iterator = self.__config["polling"]["iterator"]["persistent"]

        self._log.info("[%s] Iterator saving %s", self.get_name(), "enabled" if save_iterator else "disabled")

        if save_iterator and self.__load_iterator_config():
            self._log.info("[%s] Init iterator from file '%s': column=%s, start_value=%s",
                     self.get_name(), self.__iterator_file_name,
                     self.__iterator["name"], self.__iterator["value"])
            return True

        self.__iterator = {"name": self.__config["polling"]["iterator"]["column"],
                           "total": 0}

        if "value" in self.__config["polling"]["iterator"]:
            self.__iterator["value"] = self.__config["polling"]["iterator"]["value"]
            self._log.info("[%s] Init iterator from configuration: column=%s, start_value=%s",
                           self.get_name(), self.__iterator["name"], self.__iterator["value"])
        elif "query" in self.__config["polling"]["iterator"]:
            try:
                self.__iterator["value"] = \
                    self.__cursor.execute(self.__config["polling"]["iterator"]["query"]).fetchone()[0]
                self._log.info("[%s] Init iterator from database: column=%s, start_value=%s",
                               self.get_name(), self.__iterator["name"], self.__iterator["value"])
            except pyodbc.Warning as w:
                self._log.warning("[%s] Warning on init iterator from database: %s", self.get_name(), str(w))
            except pyodbc.Error as e:
                self._log.error("[%s] Failed to init iterator from database: %s", self.get_name(), str(e))
        else:
            self._log.error("[%s] Failed to init iterator: value/query param is absent", self.get_name())

        return "value" in self.__iterator

    def __save_iterator_config(self):
        try:
            Path(self.__config_dir).mkdir(exist_ok=True)
            with Path(self.__config_dir + self.__iterator_file_name).open("w") as iterator_file:
                iterator_file.write(dumps(self.__iterator, indent=2, sort_keys=True))
            self._log.debug("[%s] Saved iterator configuration to %s", self.get_name(), self.__iterator_file_name)
        except Exception as e:
            self._log.error("[%s] Failed to save iterator configuration to %s: %s",
                            self.get_name(), self.__iterator_file_name, str(e))

    def __load_iterator_config(self):
        if not self.__iterator_file_name:
            if not self.__resolve_iterator_file():
                self._log.error("[%s] Unable to load iterator configuration from file: file name is not resolved",
                                self.get_name())
                return False

        try:
            iterator_file_path = Path(self.__config_dir + self.__iterator_file_name)
            if not iterator_file_path.exists():
                return False

            with iterator_file_path.open("r") as iterator_file:
                self.__iterator = load(iterator_file)
            self._log.debug("[%s] Loaded iterator configuration from %s", self.get_name(), self.__iterator_file_name)
        except Exception as e:
            self._log.error("[%s] Failed to load iterator configuration from %s: %s",
                            self.get_name(), self.__iterator_file_name, str(e))

        return bool(self.__iterator)

    def __configure_pyodbc(self):
        pyodbc_config = self.__config.get("pyodbc", {})
        if not pyodbc_config:
            return

        for name, value in pyodbc_config.items():
            pyodbc.__dict__[name] = value

        self._log.info("[%s] Set pyodbc attributes: %s", self.get_name(), pyodbc_config)

    def __parse_rpc_config(self):
        if "serverSideRpc" not in self.__config:
            self.__config["serverSideRpc"] = {}
        if "enableUnknownRpc" not in self.__config["serverSideRpc"]:
            self.__config["serverSideRpc"]["enableUnknownRpc"] = self.DEFAULT_ENABLE_UNKNOWN_RPC

        self._log.info("[%s] Processing unknown RPC %s", self.get_name(),
                       "enabled" if self.__config["serverSideRpc"]["enableUnknownRpc"] else "disabled")

        if "overrideRpcConfig" not in self.__config["serverSideRpc"]:
            self.__config["serverSideRpc"]["overrideRpcConfig"] = self.DEFAULT_OVERRIDE_RPC_PARAMS

        self._log.info("[%s] Overriding RPC config %s", self.get_name(),
                       "enabled" if self.__config["serverSideRpc"]["overrideRpcConfig"] else "disabled")

        if "serverSideRpc" not in self.__config or not self.__config["serverSideRpc"].get("methods", []):
            self.__config["serverSideRpc"] = {"methods": {}}
            return

        reformatted_config = {}
        for rpc_config in self.__config["serverSideRpc"]["methods"]:
            if isinstance(rpc_config, str):
                reformatted_config[rpc_config] = {}
            elif isinstance(rpc_config, dict):
                reformatted_config[rpc_config["name"]] = rpc_config
            else:
                self._log.warning("[%s] Wrong RPC config format. Expected str or dict, get %s", self.get_name(),
                                  type(rpc_config))

        self.__config["serverSideRpc"]["methods"] = reformatted_config

    def get_config(self):
        return self.__config
