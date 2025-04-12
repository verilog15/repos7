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

class BindEslDeviceRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'cloudesl', '2020-02-01', 'BindEslDevice')
		self.set_method('POST')
		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())


	def get_ExtraParams(self):
		return self.get_body_params().get('ExtraParams')

	def set_ExtraParams(self,ExtraParams):
		self.add_body_params('ExtraParams', ExtraParams)

	def get_ContainerName(self):
		return self.get_body_params().get('ContainerName')

	def set_ContainerName(self,ContainerName):
		self.add_body_params('ContainerName', ContainerName)

	def get_StoreId(self):
		return self.get_body_params().get('StoreId')

	def set_StoreId(self,StoreId):
		self.add_body_params('StoreId', StoreId)

	def get_LayoutId(self):
		return self.get_body_params().get('LayoutId')

	def set_LayoutId(self,LayoutId):
		self.add_body_params('LayoutId', LayoutId)

	def get_Layer(self):
		return self.get_body_params().get('Layer')

	def set_Layer(self,Layer):
		self.add_body_params('Layer', Layer)

	def get_EslBarCode(self):
		return self.get_body_params().get('EslBarCode')

	def set_EslBarCode(self,EslBarCode):
		self.add_body_params('EslBarCode', EslBarCode)

	def get_LayoutName(self):
		return self.get_body_params().get('LayoutName')

	def set_LayoutName(self,LayoutName):
		self.add_body_params('LayoutName', LayoutName)

	def get_ItemBarCode(self):
		return self.get_body_params().get('ItemBarCode')

	def set_ItemBarCode(self,ItemBarCode):
		self.add_body_params('ItemBarCode', ItemBarCode)

	def get_Column(self):
		return self.get_body_params().get('Column')

	def set_Column(self,Column):
		self.add_body_params('Column', Column)

	def get_Shelf(self):
		return self.get_body_params().get('Shelf')

	def set_Shelf(self,Shelf):
		self.add_body_params('Shelf', Shelf)

	def get_ContainerId(self):
		return self.get_body_params().get('ContainerId')

	def set_ContainerId(self,ContainerId):
		self.add_body_params('ContainerId', ContainerId)