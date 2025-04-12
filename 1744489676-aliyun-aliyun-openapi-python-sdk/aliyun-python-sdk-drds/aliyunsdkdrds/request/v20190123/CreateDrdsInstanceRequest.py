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
from aliyunsdkdrds.endpoint import endpoint_data

class CreateDrdsInstanceRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Drds', '2019-01-23', 'CreateDrdsInstance','drds')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_IsAutoRenew(self): # Boolean
		return self.get_query_params().get('IsAutoRenew')

	def set_IsAutoRenew(self, IsAutoRenew):  # Boolean
		self.add_query_param('IsAutoRenew', IsAutoRenew)
	def get_ClientToken(self): # String
		return self.get_query_params().get('ClientToken')

	def set_ClientToken(self, ClientToken):  # String
		self.add_query_param('ClientToken', ClientToken)
	def get_Description(self): # String
		return self.get_query_params().get('Description')

	def set_Description(self, Description):  # String
		self.add_query_param('Description', Description)
	def get_Type(self): # String
		return self.get_query_params().get('Type')

	def set_Type(self, Type):  # String
		self.add_query_param('Type', Type)
	def get_Duration(self): # Integer
		return self.get_query_params().get('Duration')

	def set_Duration(self, Duration):  # Integer
		self.add_query_param('Duration', Duration)
	def get_ResourceGroupId(self): # String
		return self.get_query_params().get('ResourceGroupId')

	def set_ResourceGroupId(self, ResourceGroupId):  # String
		self.add_query_param('ResourceGroupId', ResourceGroupId)
	def get_isHa(self): # Boolean
		return self.get_query_params().get('isHa')

	def set_isHa(self, isHa):  # Boolean
		self.add_query_param('isHa', isHa)
	def get_MySQLVersion(self): # Integer
		return self.get_query_params().get('MySQLVersion')

	def set_MySQLVersion(self, MySQLVersion):  # Integer
		self.add_query_param('MySQLVersion', MySQLVersion)
	def get_InstanceSeries(self): # String
		return self.get_query_params().get('InstanceSeries')

	def set_InstanceSeries(self, InstanceSeries):  # String
		self.add_query_param('InstanceSeries', InstanceSeries)
	def get_MasterInstId(self): # String
		return self.get_query_params().get('MasterInstId')

	def set_MasterInstId(self, MasterInstId):  # String
		self.add_query_param('MasterInstId', MasterInstId)
	def get_Quantity(self): # Integer
		return self.get_query_params().get('Quantity')

	def set_Quantity(self, Quantity):  # Integer
		self.add_query_param('Quantity', Quantity)
	def get_Specification(self): # String
		return self.get_query_params().get('Specification')

	def set_Specification(self, Specification):  # String
		self.add_query_param('Specification', Specification)
	def get_VswitchId(self): # String
		return self.get_query_params().get('VswitchId')

	def set_VswitchId(self, VswitchId):  # String
		self.add_query_param('VswitchId', VswitchId)
	def get_VpcId(self): # String
		return self.get_query_params().get('VpcId')

	def set_VpcId(self, VpcId):  # String
		self.add_query_param('VpcId', VpcId)
	def get_ZoneId(self): # String
		return self.get_query_params().get('ZoneId')

	def set_ZoneId(self, ZoneId):  # String
		self.add_query_param('ZoneId', ZoneId)
	def get_PayType(self): # String
		return self.get_query_params().get('PayType')

	def set_PayType(self, PayType):  # String
		self.add_query_param('PayType', PayType)
	def get_PricingCycle(self): # String
		return self.get_query_params().get('PricingCycle')

	def set_PricingCycle(self, PricingCycle):  # String
		self.add_query_param('PricingCycle', PricingCycle)
