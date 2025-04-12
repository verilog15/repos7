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
from aliyunsdkdyplsapi.endpoint import endpoint_data

class BuySecretNoRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Dyplsapi', '2017-05-25', 'BuySecretNo')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_SpecId(self): # Long
		return self.get_query_params().get('SpecId')

	def set_SpecId(self, SpecId):  # Long
		self.add_query_param('SpecId', SpecId)
	def get_ResourceOwnerId(self): # Long
		return self.get_query_params().get('ResourceOwnerId')

	def set_ResourceOwnerId(self, ResourceOwnerId):  # Long
		self.add_query_param('ResourceOwnerId', ResourceOwnerId)
	def get_City(self): # String
		return self.get_query_params().get('City')

	def set_City(self, City):  # String
		self.add_query_param('City', City)
	def get_SecretNo(self): # String
		return self.get_query_params().get('SecretNo')

	def set_SecretNo(self, SecretNo):  # String
		self.add_query_param('SecretNo', SecretNo)
	def get_ResourceOwnerAccount(self): # String
		return self.get_query_params().get('ResourceOwnerAccount')

	def set_ResourceOwnerAccount(self, ResourceOwnerAccount):  # String
		self.add_query_param('ResourceOwnerAccount', ResourceOwnerAccount)
	def get_DisplayPool(self): # Boolean
		return self.get_query_params().get('DisplayPool')

	def set_DisplayPool(self, DisplayPool):  # Boolean
		self.add_query_param('DisplayPool', DisplayPool)
	def get_OwnerId(self): # Long
		return self.get_query_params().get('OwnerId')

	def set_OwnerId(self, OwnerId):  # Long
		self.add_query_param('OwnerId', OwnerId)
	def get_PoolKey(self): # String
		return self.get_query_params().get('PoolKey')

	def set_PoolKey(self, PoolKey):  # String
		self.add_query_param('PoolKey', PoolKey)
