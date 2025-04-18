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
from aliyunsdkvpc.endpoint import endpoint_data

class ModifyVpcAttributeRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Vpc', '2016-04-28', 'ModifyVpcAttribute','vpc')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_ResourceOwnerId(self): # Long
		return self.get_query_params().get('ResourceOwnerId')

	def set_ResourceOwnerId(self, ResourceOwnerId):  # Long
		self.add_query_param('ResourceOwnerId', ResourceOwnerId)
	def get_EnableIPv6(self): # Boolean
		return self.get_query_params().get('EnableIPv6')

	def set_EnableIPv6(self, EnableIPv6):  # Boolean
		self.add_query_param('EnableIPv6', EnableIPv6)
	def get_Description(self): # String
		return self.get_query_params().get('Description')

	def set_Description(self, Description):  # String
		self.add_query_param('Description', Description)
	def get_VpcName(self): # String
		return self.get_query_params().get('VpcName')

	def set_VpcName(self, VpcName):  # String
		self.add_query_param('VpcName', VpcName)
	def get_Ipv6Isp(self): # String
		return self.get_query_params().get('Ipv6Isp')

	def set_Ipv6Isp(self, Ipv6Isp):  # String
		self.add_query_param('Ipv6Isp', Ipv6Isp)
	def get_EnableDnsHostname(self): # Boolean
		return self.get_query_params().get('EnableDnsHostname')

	def set_EnableDnsHostname(self, EnableDnsHostname):  # Boolean
		self.add_query_param('EnableDnsHostname', EnableDnsHostname)
	def get_ResourceOwnerAccount(self): # String
		return self.get_query_params().get('ResourceOwnerAccount')

	def set_ResourceOwnerAccount(self, ResourceOwnerAccount):  # String
		self.add_query_param('ResourceOwnerAccount', ResourceOwnerAccount)
	def get_OwnerAccount(self): # String
		return self.get_query_params().get('OwnerAccount')

	def set_OwnerAccount(self, OwnerAccount):  # String
		self.add_query_param('OwnerAccount', OwnerAccount)
	def get_OwnerId(self): # Long
		return self.get_query_params().get('OwnerId')

	def set_OwnerId(self, OwnerId):  # Long
		self.add_query_param('OwnerId', OwnerId)
	def get_Ipv6CidrBlock(self): # String
		return self.get_query_params().get('Ipv6CidrBlock')

	def set_Ipv6CidrBlock(self, Ipv6CidrBlock):  # String
		self.add_query_param('Ipv6CidrBlock', Ipv6CidrBlock)
	def get_VpcId(self): # String
		return self.get_query_params().get('VpcId')

	def set_VpcId(self, VpcId):  # String
		self.add_query_param('VpcId', VpcId)
	def get_CidrBlock(self): # String
		return self.get_query_params().get('CidrBlock')

	def set_CidrBlock(self, CidrBlock):  # String
		self.add_query_param('CidrBlock', CidrBlock)
