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
from aliyunsdkimm.endpoint import endpoint_data
import json

class ListTasksRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'imm', '2020-09-30', 'ListTasks','imm')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_StartTimeRange(self): # Struct
		return self.get_query_params().get('StartTimeRange')

	def set_StartTimeRange(self, StartTimeRange):  # Struct
		self.add_query_param("StartTimeRange", json.dumps(StartTimeRange))
	def get_NextToken(self): # String
		return self.get_query_params().get('NextToken')

	def set_NextToken(self, NextToken):  # String
		self.add_query_param('NextToken', NextToken)
	def get_Order(self): # String
		return self.get_query_params().get('Order')

	def set_Order(self, Order):  # String
		self.add_query_param('Order', Order)
	def get_ProjectName(self): # String
		return self.get_query_params().get('ProjectName')

	def set_ProjectName(self, ProjectName):  # String
		self.add_query_param('ProjectName', ProjectName)
	def get_TaskTypes(self): # Array
		return self.get_query_params().get('TaskTypes')

	def set_TaskTypes(self, TaskTypes):  # Array
		self.add_query_param("TaskTypes", json.dumps(TaskTypes))
	def get_EndTimeRange(self): # Struct
		return self.get_query_params().get('EndTimeRange')

	def set_EndTimeRange(self, EndTimeRange):  # Struct
		self.add_query_param("EndTimeRange", json.dumps(EndTimeRange))
	def get_Sort(self): # String
		return self.get_query_params().get('Sort')

	def set_Sort(self, Sort):  # String
		self.add_query_param('Sort', Sort)
	def get_RequestDefinition(self): # Boolean
		return self.get_query_params().get('RequestDefinition')

	def set_RequestDefinition(self, RequestDefinition):  # Boolean
		self.add_query_param('RequestDefinition', RequestDefinition)
	def get_MaxResults(self): # Long
		return self.get_query_params().get('MaxResults')

	def set_MaxResults(self, MaxResults):  # Long
		self.add_query_param('MaxResults', MaxResults)
	def get_TagSelector(self): # String
		return self.get_query_params().get('TagSelector')

	def set_TagSelector(self, TagSelector):  # String
		self.add_query_param('TagSelector', TagSelector)
	def get_Status(self): # String
		return self.get_query_params().get('Status')

	def set_Status(self, Status):  # String
		self.add_query_param('Status', Status)
