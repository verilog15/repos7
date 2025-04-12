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
from aliyunsdkunimkt.endpoint import endpoint_data

class SendTaokeInfoRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'UniMkt', '2018-12-12', 'SendTaokeInfo')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_ProductId(self): # String
		return self.get_body_params().get('ProductId')

	def set_ProductId(self, ProductId):  # String
		self.add_body_params('ProductId', ProductId)
	def get_Gender(self): # String
		return self.get_body_params().get('Gender')

	def set_Gender(self, Gender):  # String
		self.add_body_params('Gender', Gender)
	def get_City(self): # String
		return self.get_body_params().get('City')

	def set_City(self, City):  # String
		self.add_body_params('City', City)
	def get_UserId(self): # String
		return self.get_body_params().get('UserId')

	def set_UserId(self, UserId):  # String
		self.add_body_params('UserId', UserId)
	def get_Mac(self): # String
		return self.get_body_params().get('Mac')

	def set_Mac(self, Mac):  # String
		self.add_body_params('Mac', Mac)
	def get_Province(self): # String
		return self.get_body_params().get('Province')

	def set_Province(self, Province):  # String
		self.add_body_params('Province', Province)
	def get_ProductTitle(self): # String
		return self.get_body_params().get('ProductTitle')

	def set_ProductTitle(self, ProductTitle):  # String
		self.add_body_params('ProductTitle', ProductTitle)
	def get_BrandId(self): # String
		return self.get_body_params().get('BrandId')

	def set_BrandId(self, BrandId):  # String
		self.add_body_params('BrandId', BrandId)
	def get_SellPrice(self): # String
		return self.get_body_params().get('SellPrice')

	def set_SellPrice(self, SellPrice):  # String
		self.add_body_params('SellPrice', SellPrice)
	def get_Plat(self): # String
		return self.get_body_params().get('Plat')

	def set_Plat(self, Plat):  # String
		self.add_body_params('Plat', Plat)
	def get_ComponentId(self): # String
		return self.get_body_params().get('ComponentId')

	def set_ComponentId(self, ComponentId):  # String
		self.add_body_params('ComponentId', ComponentId)
	def get_Address(self): # String
		return self.get_body_params().get('Address')

	def set_Address(self, Address):  # String
		self.add_body_params('Address', Address)
	def get_Ip(self): # String
		return self.get_body_params().get('Ip')

	def set_Ip(self, Ip):  # String
		self.add_body_params('Ip', Ip)
	def get_MediaId(self): # String
		return self.get_body_params().get('MediaId')

	def set_MediaId(self, MediaId):  # String
		self.add_body_params('MediaId', MediaId)
	def get_Phone(self): # String
		return self.get_body_params().get('Phone')

	def set_Phone(self, Phone):  # String
		self.add_body_params('Phone', Phone)
	def get_V(self): # String
		return self.get_body_params().get('V')

	def set_V(self, V):  # String
		self.add_body_params('V', V)
	def get_EnvironmentType(self): # String
		return self.get_body_params().get('EnvironmentType')

	def set_EnvironmentType(self, EnvironmentType):  # String
		self.add_body_params('EnvironmentType', EnvironmentType)
	def get_District(self): # String
		return self.get_body_params().get('District')

	def set_District(self, District):  # String
		self.add_body_params('District', District)
	def get_Imei(self): # String
		return self.get_body_params().get('Imei')

	def set_Imei(self, Imei):  # String
		self.add_body_params('Imei', Imei)
	def get_PayPrice(self): # String
		return self.get_body_params().get('PayPrice')

	def set_PayPrice(self, PayPrice):  # String
		self.add_body_params('PayPrice', PayPrice)
	def get_ChannelId(self): # String
		return self.get_body_params().get('ChannelId')

	def set_ChannelId(self, ChannelId):  # String
		self.add_body_params('ChannelId', ChannelId)
	def get_Age(self): # String
		return self.get_body_params().get('Age')

	def set_Age(self, Age):  # String
		self.add_body_params('Age', Age)
	def get_Status(self): # String
		return self.get_body_params().get('Status')

	def set_Status(self, Status):  # String
		self.add_body_params('Status', Status)
