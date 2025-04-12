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
from aliyunsdkarms.endpoint import endpoint_data

class CreateOrUpdateContactRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'ARMS', '2019-08-08', 'CreateOrUpdateContact','arms')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_ContactId(self): # Long
		return self.get_body_params().get('ContactId')

	def set_ContactId(self, ContactId):  # Long
		self.add_body_params('ContactId', ContactId)
	def get_ReissueSendNotice(self): # Long
		return self.get_body_params().get('ReissueSendNotice')

	def set_ReissueSendNotice(self, ReissueSendNotice):  # Long
		self.add_body_params('ReissueSendNotice', ReissueSendNotice)
	def get_CorpUserId(self): # String
		return self.get_body_params().get('CorpUserId')

	def set_CorpUserId(self, CorpUserId):  # String
		self.add_body_params('CorpUserId', CorpUserId)
	def get_ContactName(self): # String
		return self.get_body_params().get('ContactName')

	def set_ContactName(self, ContactName):  # String
		self.add_body_params('ContactName', ContactName)
	def get_ResourceGroupId(self): # String
		return self.get_query_params().get('ResourceGroupId')

	def set_ResourceGroupId(self, ResourceGroupId):  # String
		self.add_query_param('ResourceGroupId', ResourceGroupId)
	def get_DingRobotUrl(self): # String
		return self.get_query_params().get('DingRobotUrl')

	def set_DingRobotUrl(self, DingRobotUrl):  # String
		self.add_query_param('DingRobotUrl', DingRobotUrl)
	def get_Phone(self): # String
		return self.get_body_params().get('Phone')

	def set_Phone(self, Phone):  # String
		self.add_body_params('Phone', Phone)
	def get_Email(self): # String
		return self.get_body_params().get('Email')

	def set_Email(self, Email):  # String
		self.add_body_params('Email', Email)
	def get_IsEmailVerify(self): # Boolean
		return self.get_body_params().get('IsEmailVerify')

	def set_IsEmailVerify(self, IsEmailVerify):  # Boolean
		self.add_body_params('IsEmailVerify', IsEmailVerify)
