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
from aliyunsdktag.endpoint import endpoint_data

class ListSupportResourceTypesRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Tag', '2018-08-28', 'ListSupportResourceTypes','tag')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_ProductCode(self): # String
		return self.get_query_params().get('ProductCode')

	def set_ProductCode(self, ProductCode):  # String
		self.add_query_param('ProductCode', ProductCode)
	def get_SupportCode(self): # String
		return self.get_query_params().get('SupportCode')

	def set_SupportCode(self, SupportCode):  # String
		self.add_query_param('SupportCode', SupportCode)
	def get_NextToken(self): # String
		return self.get_query_params().get('NextToken')

	def set_NextToken(self, NextToken):  # String
		self.add_query_param('NextToken', NextToken)
	def get_ResourceOwnerAccount(self): # String
		return self.get_query_params().get('ResourceOwnerAccount')

	def set_ResourceOwnerAccount(self, ResourceOwnerAccount):  # String
		self.add_query_param('ResourceOwnerAccount', ResourceOwnerAccount)
	def get_OwnerAccount(self): # String
		return self.get_query_params().get('OwnerAccount')

	def set_OwnerAccount(self, OwnerAccount):  # String
		self.add_query_param('OwnerAccount', OwnerAccount)
	def get_ResourceTye(self): # String
		return self.get_query_params().get('ResourceTye')

	def set_ResourceTye(self, ResourceTye):  # String
		self.add_query_param('ResourceTye', ResourceTye)
	def get_OwnerId(self): # Long
		return self.get_query_params().get('OwnerId')

	def set_OwnerId(self, OwnerId):  # Long
		self.add_query_param('OwnerId', OwnerId)
	def get_MaxResult(self): # Integer
		return self.get_query_params().get('MaxResult')

	def set_MaxResult(self, MaxResult):  # Integer
		self.add_query_param('MaxResult', MaxResult)
	def get_ShowItems(self): # Boolean
		return self.get_query_params().get('ShowItems')

	def set_ShowItems(self, ShowItems):  # Boolean
		self.add_query_param('ShowItems', ShowItems)
