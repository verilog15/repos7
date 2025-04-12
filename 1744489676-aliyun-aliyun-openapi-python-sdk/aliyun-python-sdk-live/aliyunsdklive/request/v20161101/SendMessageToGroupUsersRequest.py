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
from aliyunsdklive.endpoint import endpoint_data

class SendMessageToGroupUsersRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'live', '2016-11-01', 'SendMessageToGroupUsers','live')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_Data(self): # String
		return self.get_body_params().get('Data')

	def set_Data(self, Data):  # String
		self.add_body_params('Data', Data)
	def get_SkipAudit(self): # Boolean
		return self.get_query_params().get('SkipAudit')

	def set_SkipAudit(self, SkipAudit):  # Boolean
		self.add_query_param('SkipAudit', SkipAudit)
	def get_Type(self): # Integer
		return self.get_body_params().get('Type')

	def set_Type(self, Type):  # Integer
		self.add_body_params('Type', Type)
	def get_OperatorUserId(self): # String
		return self.get_body_params().get('OperatorUserId')

	def set_OperatorUserId(self, OperatorUserId):  # String
		self.add_body_params('OperatorUserId', OperatorUserId)
	def get_ReceiverIdList(self): # Array
		return self.get_body_params().get('ReceiverIdList')

	def set_ReceiverIdList(self, ReceiverIdList):  # Array
		for index1, value1 in enumerate(ReceiverIdList):
			self.add_body_params('ReceiverIdList.' + str(index1 + 1), value1)
	def get_GroupId(self): # String
		return self.get_body_params().get('GroupId')

	def set_GroupId(self, GroupId):  # String
		self.add_body_params('GroupId', GroupId)
	def get_AppId(self): # String
		return self.get_body_params().get('AppId')

	def set_AppId(self, AppId):  # String
		self.add_body_params('AppId', AppId)
