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

class ListABMetricGroupsRequest(RoaRequest):

	def __init__(self):
		RoaRequest.__init__(self, 'PaiRecService', '2022-12-13', 'ListABMetricGroups')
		self.set_uri_pattern('/api/v1/abmetricgroups')
		self.set_method('GET')

	def get_Realtime(self): # Boolean
		return self.get_query_params().get('Realtime')

	def set_Realtime(self, Realtime):  # Boolean
		self.add_query_param('Realtime', Realtime)
	def get_InstanceId(self): # String
		return self.get_query_params().get('InstanceId')

	def set_InstanceId(self, InstanceId):  # String
		self.add_query_param('InstanceId', InstanceId)
	def get_SceneId(self): # String
		return self.get_query_params().get('SceneId')

	def set_SceneId(self, SceneId):  # String
		self.add_query_param('SceneId', SceneId)
	def get_PageSize(self): # Integer
		return self.get_query_params().get('PageSize')

	def set_PageSize(self, PageSize):  # Integer
		self.add_query_param('PageSize', PageSize)
	def get_PageNumber(self): # Integer
		return self.get_query_params().get('PageNumber')

	def set_PageNumber(self, PageNumber):  # Integer
		self.add_query_param('PageNumber', PageNumber)
