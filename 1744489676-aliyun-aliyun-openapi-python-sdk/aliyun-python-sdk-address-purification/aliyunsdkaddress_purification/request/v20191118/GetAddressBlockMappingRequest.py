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
from aliyunsdkaddress_purification.endpoint import endpoint_data

class GetAddressBlockMappingRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'address-purification', '2019-11-18', 'GetAddressBlockMapping','addrp')
		self.set_method('POST')
		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())


	def get_DefaultProvince(self):
		return self.get_body_params().get('DefaultProvince')

	def set_DefaultProvince(self,DefaultProvince):
		self.add_body_params('DefaultProvince', DefaultProvince)

	def get_ServiceCode(self):
		return self.get_body_params().get('ServiceCode')

	def set_ServiceCode(self,ServiceCode):
		self.add_body_params('ServiceCode', ServiceCode)

	def get_DefaultCity(self):
		return self.get_body_params().get('DefaultCity')

	def set_DefaultCity(self,DefaultCity):
		self.add_body_params('DefaultCity', DefaultCity)

	def get_DefaultDistrict(self):
		return self.get_body_params().get('DefaultDistrict')

	def set_DefaultDistrict(self,DefaultDistrict):
		self.add_body_params('DefaultDistrict', DefaultDistrict)

	def get_AppKey(self):
		return self.get_body_params().get('AppKey')

	def set_AppKey(self,AppKey):
		self.add_body_params('AppKey', AppKey)

	def get_Text(self):
		return self.get_body_params().get('Text')

	def set_Text(self,Text):
		self.add_body_params('Text', Text)