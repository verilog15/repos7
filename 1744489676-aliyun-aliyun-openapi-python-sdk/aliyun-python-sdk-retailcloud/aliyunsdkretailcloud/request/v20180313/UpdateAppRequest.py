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
from aliyunsdkretailcloud.endpoint import endpoint_data

class UpdateAppRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'retailcloud', '2018-03-13', 'UpdateApp')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_BizTitle(self): # String
		return self.get_body_params().get('BizTitle')

	def set_BizTitle(self, BizTitle):  # String
		self.add_body_params('BizTitle', BizTitle)
	def get_ServiceType(self): # String
		return self.get_body_params().get('ServiceType')

	def set_ServiceType(self, ServiceType):  # String
		self.add_body_params('ServiceType', ServiceType)
	def get_UserRoless(self): # RepeatList
		return self.get_body_params().get('UserRoles')

	def set_UserRoless(self, UserRoles):  # RepeatList
		for depth1 in range(len(UserRoles)):
			if UserRoles[depth1].get('RoleName') is not None:
				self.add_body_params('UserRoles.' + str(depth1 + 1) + '.RoleName', UserRoles[depth1].get('RoleName'))
			if UserRoles[depth1].get('UserType') is not None:
				self.add_body_params('UserRoles.' + str(depth1 + 1) + '.UserType', UserRoles[depth1].get('UserType'))
			if UserRoles[depth1].get('UserId') is not None:
				self.add_body_params('UserRoles.' + str(depth1 + 1) + '.UserId', UserRoles[depth1].get('UserId'))
	def get_AppId(self): # Long
		return self.get_body_params().get('AppId')

	def set_AppId(self, AppId):  # Long
		self.add_body_params('AppId', AppId)
	def get_OperatingSystem(self): # String
		return self.get_body_params().get('OperatingSystem')

	def set_OperatingSystem(self, OperatingSystem):  # String
		self.add_body_params('OperatingSystem', OperatingSystem)
	def get_Description(self): # String
		return self.get_body_params().get('Description')

	def set_Description(self, Description):  # String
		self.add_body_params('Description', Description)
	def get_Language(self): # String
		return self.get_body_params().get('Language')

	def set_Language(self, Language):  # String
		self.add_body_params('Language', Language)
	def get_MiddleWareIdLists(self): # RepeatList
		return self.get_body_params().get('MiddleWareIdList')

	def set_MiddleWareIdLists(self, MiddleWareIdList):  # RepeatList
		for depth1 in range(len(MiddleWareIdList)):
			self.add_body_params('MiddleWareIdList.' + str(depth1 + 1), MiddleWareIdList[depth1])
