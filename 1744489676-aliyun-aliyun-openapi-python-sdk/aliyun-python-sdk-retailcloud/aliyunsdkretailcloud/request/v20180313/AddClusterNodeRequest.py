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
from aliyunsdkretailcloud.endpoint import endpoint_data

class AddClusterNodeRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'retailcloud', '2018-03-13', 'AddClusterNode')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_EcsInstanceIdLists(self): # RepeatList
		return self.get_query_params().get('EcsInstanceIdList')

	def set_EcsInstanceIdLists(self, EcsInstanceIdList):  # RepeatList
		for depth1 in range(len(EcsInstanceIdList)):
			self.add_query_param('EcsInstanceIdList.' + str(depth1 + 1), EcsInstanceIdList[depth1])
	def get_ClusterInstanceId(self): # String
		return self.get_query_params().get('ClusterInstanceId')

	def set_ClusterInstanceId(self, ClusterInstanceId):  # String
		self.add_query_param('ClusterInstanceId', ClusterInstanceId)
