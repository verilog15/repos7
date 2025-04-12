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

class ListCommonGroupRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'devops-rdc', '2020-03-03', 'ListCommonGroup')
		self.set_method('POST')

	def get_All(self): # Boolean
		return self.get_body_params().get('All')

	def set_All(self, All):  # Boolean
		self.add_body_params('All', All)
	def get_SmartGroupId(self): # String
		return self.get_body_params().get('SmartGroupId')

	def set_SmartGroupId(self, SmartGroupId):  # String
		self.add_body_params('SmartGroupId', SmartGroupId)
	def get_ProjectId(self): # String
		return self.get_body_params().get('ProjectId')

	def set_ProjectId(self, ProjectId):  # String
		self.add_body_params('ProjectId', ProjectId)
	def get_OrgId(self): # String
		return self.get_body_params().get('OrgId')

	def set_OrgId(self, OrgId):  # String
		self.add_body_params('OrgId', OrgId)
