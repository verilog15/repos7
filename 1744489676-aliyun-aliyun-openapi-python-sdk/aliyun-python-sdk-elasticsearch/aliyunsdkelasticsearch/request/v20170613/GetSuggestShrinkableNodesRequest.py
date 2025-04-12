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
from aliyunsdkelasticsearch.endpoint import endpoint_data

class GetSuggestShrinkableNodesRequest(RoaRequest):

	def __init__(self):
		RoaRequest.__init__(self, 'elasticsearch', '2017-06-13', 'GetSuggestShrinkableNodes','elasticsearch')
		self.set_uri_pattern('/openapi/instances/[InstanceId]/suggest-shrinkable-nodes')
		self.set_method('GET')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_ignoreStatus(self): # Boolean
		return self.get_query_params().get('ignoreStatus')

	def set_ignoreStatus(self, ignoreStatus):  # Boolean
		self.add_query_param('ignoreStatus', ignoreStatus)
	def get_InstanceId(self): # String
		return self.get_path_params().get('InstanceId')

	def set_InstanceId(self, InstanceId):  # String
		self.add_path_param('InstanceId', InstanceId)
	def get_nodeType(self): # String
		return self.get_query_params().get('nodeType')

	def set_nodeType(self, nodeType):  # String
		self.add_query_param('nodeType', nodeType)
	def get_count(self): # Integer
		return self.get_query_params().get('count')

	def set_count(self, count):  # Integer
		self.add_query_param('count', count)
