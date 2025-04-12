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

class UpdateDevopsProjectSprintRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'devops-rdc', '2020-03-03', 'UpdateDevopsProjectSprint')
		self.set_method('POST')

	def get_ExecutorId(self): # String
		return self.get_body_params().get('ExecutorId')

	def set_ExecutorId(self, ExecutorId):  # String
		self.add_body_params('ExecutorId', ExecutorId)
	def get_Description(self): # String
		return self.get_body_params().get('Description')

	def set_Description(self, Description):  # String
		self.add_body_params('Description', Description)
	def get_StartDate(self): # String
		return self.get_body_params().get('StartDate')

	def set_StartDate(self, StartDate):  # String
		self.add_body_params('StartDate', StartDate)
	def get_OrgId(self): # String
		return self.get_body_params().get('OrgId')

	def set_OrgId(self, OrgId):  # String
		self.add_body_params('OrgId', OrgId)
	def get_SprintId(self): # String
		return self.get_body_params().get('SprintId')

	def set_SprintId(self, SprintId):  # String
		self.add_body_params('SprintId', SprintId)
	def get_DueDate(self): # String
		return self.get_body_params().get('DueDate')

	def set_DueDate(self, DueDate):  # String
		self.add_body_params('DueDate', DueDate)
	def get_Name(self): # String
		return self.get_body_params().get('Name')

	def set_Name(self, Name):  # String
		self.add_body_params('Name', Name)
	def get_ProjectId(self): # String
		return self.get_body_params().get('ProjectId')

	def set_ProjectId(self, ProjectId):  # String
		self.add_body_params('ProjectId', ProjectId)
