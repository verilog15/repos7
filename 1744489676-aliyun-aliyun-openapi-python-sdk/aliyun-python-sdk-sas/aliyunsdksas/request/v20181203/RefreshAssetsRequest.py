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
from aliyunsdksas.endpoint import endpoint_data

class RefreshAssetsRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Sas', '2018-12-03', 'RefreshAssets','sas')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_CloudAssetSubType(self): # Integer
		return self.get_query_params().get('CloudAssetSubType')

	def set_CloudAssetSubType(self, CloudAssetSubType):  # Integer
		self.add_query_param('CloudAssetSubType', CloudAssetSubType)
	def get_Vendor(self): # Integer
		return self.get_query_params().get('Vendor')

	def set_Vendor(self, Vendor):  # Integer
		self.add_query_param('Vendor', Vendor)
	def get_AssetType(self): # String
		return self.get_query_params().get('AssetType')

	def set_AssetType(self, AssetType):  # String
		self.add_query_param('AssetType', AssetType)
	def get_CloudAssetType(self): # Integer
		return self.get_query_params().get('CloudAssetType')

	def set_CloudAssetType(self, CloudAssetType):  # Integer
		self.add_query_param('CloudAssetType', CloudAssetType)
