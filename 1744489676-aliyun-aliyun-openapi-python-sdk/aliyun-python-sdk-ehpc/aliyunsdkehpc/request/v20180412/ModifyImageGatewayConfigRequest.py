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
from aliyunsdkehpc.endpoint import endpoint_data

class ModifyImageGatewayConfigRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'EHPC', '2018-04-12', 'ModifyImageGatewayConfig','ehs')
		self.set_method('GET')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_Repos(self): # RepeatList
		return self.get_query_params().get('Repo')

	def set_Repos(self, Repo):  # RepeatList
		for depth1 in range(len(Repo)):
			if Repo[depth1].get('Auth') is not None:
				self.add_query_param('Repo.' + str(depth1 + 1) + '.Auth', Repo[depth1].get('Auth'))
			if Repo[depth1].get('Location') is not None:
				self.add_query_param('Repo.' + str(depth1 + 1) + '.Location', Repo[depth1].get('Location'))
			if Repo[depth1].get('URL') is not None:
				self.add_query_param('Repo.' + str(depth1 + 1) + '.URL', Repo[depth1].get('URL'))
	def get_DBServerInfo(self): # String
		return self.get_query_params().get('DBServerInfo')

	def set_DBServerInfo(self, DBServerInfo):  # String
		self.add_query_param('DBServerInfo', DBServerInfo)
	def get_ClusterId(self): # String
		return self.get_query_params().get('ClusterId')

	def set_ClusterId(self, ClusterId):  # String
		self.add_query_param('ClusterId', ClusterId)
	def get_DefaultRepoLocation(self): # String
		return self.get_query_params().get('DefaultRepoLocation')

	def set_DefaultRepoLocation(self, DefaultRepoLocation):  # String
		self.add_query_param('DefaultRepoLocation', DefaultRepoLocation)
	def get_DBPassword(self): # String
		return self.get_query_params().get('DBPassword')

	def set_DBPassword(self, DBPassword):  # String
		self.add_query_param('DBPassword', DBPassword)
	def get_DBType(self): # String
		return self.get_query_params().get('DBType')

	def set_DBType(self, DBType):  # String
		self.add_query_param('DBType', DBType)
	def get_DBUsername(self): # String
		return self.get_query_params().get('DBUsername')

	def set_DBUsername(self, DBUsername):  # String
		self.add_query_param('DBUsername', DBUsername)
	def get_PullUpdateTimeout(self): # Integer
		return self.get_query_params().get('PullUpdateTimeout')

	def set_PullUpdateTimeout(self, PullUpdateTimeout):  # Integer
		self.add_query_param('PullUpdateTimeout', PullUpdateTimeout)
	def get_ImageExpirationTimeout(self): # String
		return self.get_query_params().get('ImageExpirationTimeout')

	def set_ImageExpirationTimeout(self, ImageExpirationTimeout):  # String
		self.add_query_param('ImageExpirationTimeout', ImageExpirationTimeout)
