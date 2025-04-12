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

from aliyunsdkcore.request import RoaRequest
from aliyunsdkedas.endpoint import endpoint_data

class UntagResourcesRequest(RoaRequest):

	def __init__(self):
		RoaRequest.__init__(self, 'Edas', '2017-08-01', 'UntagResources','Edas')
		self.set_uri_pattern('/pop/v5/tag/tags')
		self.set_method('DELETE')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_TagKeys(self): # String
		return self.get_query_params().get('TagKeys')

	def set_TagKeys(self, TagKeys):  # String
		self.add_query_param('TagKeys', TagKeys)
	def get_DeleteAll(self): # Boolean
		return self.get_query_params().get('DeleteAll')

	def set_DeleteAll(self, DeleteAll):  # Boolean
		self.add_query_param('DeleteAll', DeleteAll)
	def get_ResourceRegionId(self): # String
		return self.get_query_params().get('ResourceRegionId')

	def set_ResourceRegionId(self, ResourceRegionId):  # String
		self.add_query_param('ResourceRegionId', ResourceRegionId)
	def get_ResourceType(self): # String
		return self.get_query_params().get('ResourceType')

	def set_ResourceType(self, ResourceType):  # String
		self.add_query_param('ResourceType', ResourceType)
	def get_ResourceIds(self): # String
		return self.get_query_params().get('ResourceIds')

	def set_ResourceIds(self, ResourceIds):  # String
		self.add_query_param('ResourceIds', ResourceIds)
