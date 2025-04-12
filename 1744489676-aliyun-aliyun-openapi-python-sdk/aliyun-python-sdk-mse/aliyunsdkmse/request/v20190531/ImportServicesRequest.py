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
from aliyunsdkmse.endpoint import endpoint_data
import json

class ImportServicesRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'mse', '2019-05-31', 'ImportServices','mse')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_GatewayUniqueId(self): # String
		return self.get_query_params().get('GatewayUniqueId')

	def set_GatewayUniqueId(self, GatewayUniqueId):  # String
		self.add_query_param('GatewayUniqueId', GatewayUniqueId)
	def get_ServiceList(self): # Array
		return self.get_query_params().get('ServiceList')

	def set_ServiceList(self, ServiceList):  # Array
		self.add_query_param("ServiceList", json.dumps(ServiceList))
	def get_TlsSetting(self): # String
		return self.get_query_params().get('TlsSetting')

	def set_TlsSetting(self, TlsSetting):  # String
		self.add_query_param('TlsSetting', TlsSetting)
	def get_SourceType(self): # String
		return self.get_query_params().get('SourceType')

	def set_SourceType(self, SourceType):  # String
		self.add_query_param('SourceType', SourceType)
	def get_FcServiceName(self): # String
		return self.get_query_params().get('FcServiceName')

	def set_FcServiceName(self, FcServiceName):  # String
		self.add_query_param('FcServiceName', FcServiceName)
	def get_FcVersion(self): # String
		return self.get_query_params().get('FcVersion')

	def set_FcVersion(self, FcVersion):  # String
		self.add_query_param('FcVersion', FcVersion)
	def get_AcceptLanguage(self): # String
		return self.get_query_params().get('AcceptLanguage')

	def set_AcceptLanguage(self, AcceptLanguage):  # String
		self.add_query_param('AcceptLanguage', AcceptLanguage)
