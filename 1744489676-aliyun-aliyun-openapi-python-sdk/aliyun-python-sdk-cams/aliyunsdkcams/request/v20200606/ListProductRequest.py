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
from aliyunsdkcams.endpoint import endpoint_data

class ListProductRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'cams', '2020-06-06', 'ListProduct','cams')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_ResourceOwnerId(self): # Long
		return self.get_query_params().get('ResourceOwnerId')

	def set_ResourceOwnerId(self, ResourceOwnerId):  # Long
		self.add_query_param('ResourceOwnerId', ResourceOwnerId)
	def get_Before(self): # String
		return self.get_query_params().get('Before')

	def set_Before(self, Before):  # String
		self.add_query_param('Before', Before)
	def get_Limit(self): # Long
		return self.get_query_params().get('Limit')

	def set_Limit(self, Limit):  # Long
		self.add_query_param('Limit', Limit)
	def get_After(self): # String
		return self.get_query_params().get('After')

	def set_After(self, After):  # String
		self.add_query_param('After', After)
	def get_ResourceOwnerAccount(self): # String
		return self.get_query_params().get('ResourceOwnerAccount')

	def set_ResourceOwnerAccount(self, ResourceOwnerAccount):  # String
		self.add_query_param('ResourceOwnerAccount', ResourceOwnerAccount)
	def get_OwnerId(self): # Long
		return self.get_query_params().get('OwnerId')

	def set_OwnerId(self, OwnerId):  # Long
		self.add_query_param('OwnerId', OwnerId)
	def get_WabaId(self): # String
		return self.get_query_params().get('WabaId')

	def set_WabaId(self, WabaId):  # String
		self.add_query_param('WabaId', WabaId)
	def get_CatalogId(self): # String
		return self.get_query_params().get('CatalogId')

	def set_CatalogId(self, CatalogId):  # String
		self.add_query_param('CatalogId', CatalogId)
	def get_CustSpaceId(self): # String
		return self.get_query_params().get('CustSpaceId')

	def set_CustSpaceId(self, CustSpaceId):  # String
		self.add_query_param('CustSpaceId', CustSpaceId)
	def get_Fields(self): # String
		return self.get_query_params().get('Fields')

	def set_Fields(self, Fields):  # String
		self.add_query_param('Fields', Fields)
