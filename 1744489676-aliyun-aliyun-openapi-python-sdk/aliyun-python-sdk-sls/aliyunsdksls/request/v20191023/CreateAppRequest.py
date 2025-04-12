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

class CreateAppRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Sls', '2019-10-23', 'CreateApp','sls')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_ClientToken(self): # String
		return self.get_query_params().get('ClientToken')

	def set_ClientToken(self, ClientToken):  # String
		self.add_query_param('ClientToken', ClientToken)
	def get_SlsAccessToken(self): # String
		return self.get_query_params().get('SlsAccessToken')

	def set_SlsAccessToken(self, SlsAccessToken):  # String
		self.add_query_param('SlsAccessToken', SlsAccessToken)
	def get_AppName(self): # String
		return self.get_query_params().get('AppName')

	def set_AppName(self, AppName):  # String
		self.add_query_param('AppName', AppName)
	def get_DisplayName(self): # String
		return self.get_query_params().get('DisplayName')

	def set_DisplayName(self, DisplayName):  # String
		self.add_query_param('DisplayName', DisplayName)
	def get_ClientIp(self): # String
		return self.get_query_params().get('ClientIp')

	def set_ClientIp(self, ClientIp):  # String
		self.add_query_param('ClientIp', ClientIp)
	def get_Config(self): # String
		return self.get_body_params().get('Config')

	def set_Config(self, Config):  # String
		self.add_body_params('Config', Config)
