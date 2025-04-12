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
from aliyunsdkdataworks_public.endpoint import endpoint_data
import json

class ListResourceGroupsRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'dataworks-public', '2020-05-18', 'ListResourceGroups')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_BizExtKey(self): # String
		return self.get_query_params().get('BizExtKey')

	def set_BizExtKey(self, BizExtKey):  # String
		self.add_query_param('BizExtKey', BizExtKey)
	def get_Tags(self): # Array
		return self.get_query_params().get('Tags')

	def set_Tags(self, Tags):  # Array
		self.add_query_param("Tags", json.dumps(Tags))
	def get_ResourceManagerResourceGroupId(self): # String
		return self.get_query_params().get('ResourceManagerResourceGroupId')

	def set_ResourceManagerResourceGroupId(self, ResourceManagerResourceGroupId):  # String
		self.add_query_param('ResourceManagerResourceGroupId', ResourceManagerResourceGroupId)
	def get_ResourceGroupType(self): # Integer
		return self.get_query_params().get('ResourceGroupType')

	def set_ResourceGroupType(self, ResourceGroupType):  # Integer
		self.add_query_param('ResourceGroupType', ResourceGroupType)
	def get_Keyword(self): # String
		return self.get_query_params().get('Keyword')

	def set_Keyword(self, Keyword):  # String
		self.add_query_param('Keyword', Keyword)
