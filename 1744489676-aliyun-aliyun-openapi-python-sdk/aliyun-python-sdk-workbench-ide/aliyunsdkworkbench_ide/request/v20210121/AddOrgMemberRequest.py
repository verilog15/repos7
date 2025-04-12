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

class AddOrgMemberRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Workbench-ide', '2021-01-21', 'AddOrgMember')
		self.set_method('POST')

	def get_Uid(self): # Long
		return self.get_query_params().get('Uid')

	def set_Uid(self, Uid):  # Long
		self.add_query_param('Uid', Uid)
	def get_Role(self): # String
		return self.get_query_params().get('Role')

	def set_Role(self, Role):  # String
		self.add_query_param('Role', Role)
	def get_CurrentOrgId(self): # String
		return self.get_query_params().get('CurrentOrgId')

	def set_CurrentOrgId(self, CurrentOrgId):  # String
		self.add_query_param('CurrentOrgId', CurrentOrgId)
	def get_AccountType(self): # String
		return self.get_query_params().get('AccountType')

	def set_AccountType(self, AccountType):  # String
		self.add_query_param('AccountType', AccountType)
