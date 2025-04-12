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

class ListMemberRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'lto', '2021-07-07', 'ListMember')
		self.set_method('POST')

	def get_Num(self): # Integer
		return self.get_query_params().get('Num')

	def set_Num(self, Num):  # Integer
		self.add_query_param('Num', Num)
	def get_Uid(self): # String
		return self.get_query_params().get('Uid')

	def set_Uid(self, Uid):  # String
		self.add_query_param('Uid', Uid)
	def get_Size(self): # Integer
		return self.get_query_params().get('Size')

	def set_Size(self, Size):  # Integer
		self.add_query_param('Size', Size)
	def get_Name(self): # String
		return self.get_query_params().get('Name')

	def set_Name(self, Name):  # String
		self.add_query_param('Name', Name)
	def get_Contactor(self): # String
		return self.get_query_params().get('Contactor')

	def set_Contactor(self, Contactor):  # String
		self.add_query_param('Contactor', Contactor)
