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
from aliyunsdkcloudesl.endpoint import endpoint_data

class UpdateStoreRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'cloudesl', '2020-02-01', 'UpdateStore')
		self.set_method('POST')
		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())


	def get_ExtraParams(self):
		return self.get_body_params().get('ExtraParams')

	def set_ExtraParams(self,ExtraParams):
		self.add_body_params('ExtraParams', ExtraParams)

	def get_Timezone(self):
		return self.get_body_params().get('Timezone')

	def set_Timezone(self,Timezone):
		self.add_body_params('Timezone', Timezone)

	def get_StoreName(self):
		return self.get_body_params().get('StoreName')

	def set_StoreName(self,StoreName):
		self.add_body_params('StoreName', StoreName)

	def get_StoreId(self):
		return self.get_body_params().get('StoreId')

	def set_StoreId(self,StoreId):
		self.add_body_params('StoreId', StoreId)

	def get_TemplateVersion(self):
		return self.get_body_params().get('TemplateVersion')

	def set_TemplateVersion(self,TemplateVersion):
		self.add_body_params('TemplateVersion', TemplateVersion)

	def get_UserStoreCode(self):
		return self.get_body_params().get('UserStoreCode')

	def set_UserStoreCode(self,UserStoreCode):
		self.add_body_params('UserStoreCode', UserStoreCode)

	def get_Phone(self):
		return self.get_body_params().get('Phone')

	def set_Phone(self,Phone):
		self.add_body_params('Phone', Phone)