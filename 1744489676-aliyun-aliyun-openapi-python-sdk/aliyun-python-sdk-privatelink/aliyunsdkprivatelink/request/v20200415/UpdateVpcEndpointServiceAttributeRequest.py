# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

from aliyunsdkcore.request import RpcRequest
from aliyunsdkprivatelink.endpoint import endpoint_data

class UpdateVpcEndpointServiceAttributeRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Privatelink', '2020-04-15', 'UpdateVpcEndpointServiceAttribute','privatelink')
		self.set_protocol_type('https')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_AutoAcceptEnabled(self): # Boolean
		return self.get_query_params().get('AutoAcceptEnabled')

	def set_AutoAcceptEnabled(self, AutoAcceptEnabled):  # Boolean
		self.add_query_param('AutoAcceptEnabled', AutoAcceptEnabled)
	def get_ClientToken(self): # String
		return self.get_query_params().get('ClientToken')

	def set_ClientToken(self, ClientToken):  # String
		self.add_query_param('ClientToken', ClientToken)
	def get_ConnectBandwidth(self): # Integer
		return self.get_query_params().get('ConnectBandwidth')

	def set_ConnectBandwidth(self, ConnectBandwidth):  # Integer
		self.add_query_param('ConnectBandwidth', ConnectBandwidth)
	def get_ZoneAffinityEnabled(self): # Boolean
		return self.get_query_params().get('ZoneAffinityEnabled')

	def set_ZoneAffinityEnabled(self, ZoneAffinityEnabled):  # Boolean
		self.add_query_param('ZoneAffinityEnabled', ZoneAffinityEnabled)
	def get_DryRun(self): # Boolean
		return self.get_query_params().get('DryRun')

	def set_DryRun(self, DryRun):  # Boolean
		self.add_query_param('DryRun', DryRun)
	def get_ServiceSupportIPv6(self): # Boolean
		return self.get_query_params().get('ServiceSupportIPv6')

	def set_ServiceSupportIPv6(self, ServiceSupportIPv6):  # Boolean
		self.add_query_param('ServiceSupportIPv6', ServiceSupportIPv6)
	def get_ServiceDescription(self): # String
		return self.get_query_params().get('ServiceDescription')

	def set_ServiceDescription(self, ServiceDescription):  # String
		self.add_query_param('ServiceDescription', ServiceDescription)
	def get_ServiceId(self): # String
		return self.get_query_params().get('ServiceId')

	def set_ServiceId(self, ServiceId):  # String
		self.add_query_param('ServiceId', ServiceId)
