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
from aliyunsdkfnf.endpoint import endpoint_data

class ListExecutionsRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'fnf', '2019-03-15', 'ListExecutions','fnf')
		self.set_method('GET')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_StartedTimeBegin(self): # String
		return self.get_query_params().get('StartedTimeBegin')

	def set_StartedTimeBegin(self, StartedTimeBegin):  # String
		self.add_query_param('StartedTimeBegin', StartedTimeBegin)
	def get_ExecutionNamePrefix(self): # String
		return self.get_query_params().get('ExecutionNamePrefix')

	def set_ExecutionNamePrefix(self, ExecutionNamePrefix):  # String
		self.add_query_param('ExecutionNamePrefix', ExecutionNamePrefix)
	def get_NextToken(self): # String
		return self.get_query_params().get('NextToken')

	def set_NextToken(self, NextToken):  # String
		self.add_query_param('NextToken', NextToken)
	def get_Limit(self): # Integer
		return self.get_query_params().get('Limit')

	def set_Limit(self, Limit):  # Integer
		self.add_query_param('Limit', Limit)
	def get_FlowName(self): # String
		return self.get_query_params().get('FlowName')

	def set_FlowName(self, FlowName):  # String
		self.add_query_param('FlowName', FlowName)
	def get_StartedTimeEnd(self): # String
		return self.get_query_params().get('StartedTimeEnd')

	def set_StartedTimeEnd(self, StartedTimeEnd):  # String
		self.add_query_param('StartedTimeEnd', StartedTimeEnd)
	def get_Status(self): # String
		return self.get_query_params().get('Status')

	def set_Status(self, Status):  # String
		self.add_query_param('Status', Status)
