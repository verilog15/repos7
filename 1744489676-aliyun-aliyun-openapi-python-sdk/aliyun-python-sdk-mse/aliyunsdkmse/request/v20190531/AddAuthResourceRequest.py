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

class AddAuthResourceRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'mse', '2019-05-31', 'AddAuthResource','mse')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_IgnoreCase(self): # Boolean
		return self.get_query_params().get('IgnoreCase')

	def set_IgnoreCase(self, IgnoreCase):  # Boolean
		self.add_query_param('IgnoreCase', IgnoreCase)
	def get_GatewayUniqueId(self): # String
		return self.get_query_params().get('GatewayUniqueId')

	def set_GatewayUniqueId(self, GatewayUniqueId):  # String
		self.add_query_param('GatewayUniqueId', GatewayUniqueId)
	def get_DomainId(self): # Long
		return self.get_query_params().get('DomainId')

	def set_DomainId(self, DomainId):  # Long
		self.add_query_param('DomainId', DomainId)
	def get_Path(self): # String
		return self.get_query_params().get('Path')

	def set_Path(self, Path):  # String
		self.add_query_param('Path', Path)
	def get_MatchType(self): # String
		return self.get_query_params().get('MatchType')

	def set_MatchType(self, MatchType):  # String
		self.add_query_param('MatchType', MatchType)
	def get_AuthId(self): # Long
		return self.get_query_params().get('AuthId')

	def set_AuthId(self, AuthId):  # Long
		self.add_query_param('AuthId', AuthId)
	def get_AuthResourceHeaderList(self): # Array
		return self.get_query_params().get('AuthResourceHeaderList')

	def set_AuthResourceHeaderList(self, AuthResourceHeaderList):  # Array
		self.add_query_param("AuthResourceHeaderList", json.dumps(AuthResourceHeaderList))
	def get_AcceptLanguage(self): # String
		return self.get_query_params().get('AcceptLanguage')

	def set_AcceptLanguage(self, AcceptLanguage):  # String
		self.add_query_param('AcceptLanguage', AcceptLanguage)
