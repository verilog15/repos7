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
from aliyunsdksls.endpoint import endpoint_data

class AnalyzeProductLogRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Sls', '2019-10-23', 'AnalyzeProductLog','sls')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_Project(self): # String
		return self.get_query_params().get('Project')

	def set_Project(self, Project):  # String
		self.add_query_param('Project', Project)
	def get_SlsAccessToken(self): # String
		return self.get_query_params().get('SlsAccessToken')

	def set_SlsAccessToken(self, SlsAccessToken):  # String
		self.add_query_param('SlsAccessToken', SlsAccessToken)
	def get_CloudProduct(self): # String
		return self.get_query_params().get('CloudProduct')

	def set_CloudProduct(self, CloudProduct):  # String
		self.add_query_param('CloudProduct', CloudProduct)
	def get_ResourceQuota(self): # String
		return self.get_query_params().get('ResourceQuota')

	def set_ResourceQuota(self, ResourceQuota):  # String
		self.add_query_param('ResourceQuota', ResourceQuota)
	def get_VariableMap(self): # String
		return self.get_query_params().get('VariableMap')

	def set_VariableMap(self, VariableMap):  # String
		self.add_query_param('VariableMap', VariableMap)
	def get_ClientIp(self): # String
		return self.get_query_params().get('ClientIp')

	def set_ClientIp(self, ClientIp):  # String
		self.add_query_param('ClientIp', ClientIp)
	def get_Lang(self): # String
		return self.get_query_params().get('Lang')

	def set_Lang(self, Lang):  # String
		self.add_query_param('Lang', Lang)
	def get_Overwrite(self): # Boolean
		return self.get_query_params().get('Overwrite')

	def set_Overwrite(self, Overwrite):  # Boolean
		self.add_query_param('Overwrite', Overwrite)
	def get_TTL(self): # Integer
		return self.get_query_params().get('TTL')

	def set_TTL(self, TTL):  # Integer
		self.add_query_param('TTL', TTL)
	def get_HotTTL(self): # Integer
		return self.get_query_params().get('HotTTL')

	def set_HotTTL(self, HotTTL):  # Integer
		self.add_query_param('HotTTL', HotTTL)
	def get_Region(self): # String
		return self.get_query_params().get('Region')

	def set_Region(self, Region):  # String
		self.add_query_param('Region', Region)
	def get_Logstore(self): # String
		return self.get_query_params().get('Logstore')

	def set_Logstore(self, Logstore):  # String
		self.add_query_param('Logstore', Logstore)
