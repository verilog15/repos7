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
from aliyunsdkarms.endpoint import endpoint_data

class SwitchSyntheticTaskStatusRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'ARMS', '2019-08-08', 'SwitchSyntheticTaskStatus','arms')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_TaskIdss(self): # RepeatList
		return self.get_query_params().get('TaskIds')

	def set_TaskIdss(self, TaskIds):  # RepeatList
		for depth1 in range(len(TaskIds)):
			self.add_query_param('TaskIds.' + str(depth1 + 1), TaskIds[depth1])
	def get_SwitchStatus(self): # Long
		return self.get_query_params().get('SwitchStatus')

	def set_SwitchStatus(self, SwitchStatus):  # Long
		self.add_query_param('SwitchStatus', SwitchStatus)
