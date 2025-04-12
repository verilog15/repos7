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
from aliyunsdkmoguan_sdk.endpoint import endpoint_data

class RegisterDeviceRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'moguan-sdk', '2021-04-15', 'RegisterDevice')
		self.set_method('POST')
		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())


	def get_UserDeviceId(self):
		return self.get_body_params().get('UserDeviceId')

	def set_UserDeviceId(self,UserDeviceId):
		self.add_body_params('UserDeviceId', UserDeviceId)

	def get_Extend(self):
		return self.get_body_params().get('Extend')

	def set_Extend(self,Extend):
		self.add_body_params('Extend', Extend)

	def get_SdkCode(self):
		return self.get_body_params().get('SdkCode')

	def set_SdkCode(self,SdkCode):
		self.add_body_params('SdkCode', SdkCode)

	def get_AppKey(self):
		return self.get_body_params().get('AppKey')

	def set_AppKey(self,AppKey):
		self.add_body_params('AppKey', AppKey)

	def get_DeviceId(self):
		return self.get_body_params().get('DeviceId')

	def set_DeviceId(self,DeviceId):
		self.add_body_params('DeviceId', DeviceId)