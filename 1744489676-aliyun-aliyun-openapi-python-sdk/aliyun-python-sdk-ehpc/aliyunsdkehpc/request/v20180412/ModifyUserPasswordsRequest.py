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

class ModifyUserPasswordsRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'EHPC', '2018-04-12', 'ModifyUserPasswords','ehs')
		self.set_method('GET')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_ClusterId(self): # String
		return self.get_query_params().get('ClusterId')

	def set_ClusterId(self, ClusterId):  # String
		self.add_query_param('ClusterId', ClusterId)
	def get_Async(self): # Boolean
		return self.get_query_params().get('Async')

	def set_Async(self, _Async):  # Boolean
		self.add_query_param('Async', _Async)
	def get_Users(self): # RepeatList
		return self.get_query_params().get('User')

	def set_Users(self, User):  # RepeatList
		for depth1 in range(len(User)):
			if User[depth1].get('Password') is not None:
				self.add_query_param('User.' + str(depth1 + 1) + '.Password', User[depth1].get('Password'))
			if User[depth1].get('Name') is not None:
				self.add_query_param('User.' + str(depth1 + 1) + '.Name', User[depth1].get('Name'))
