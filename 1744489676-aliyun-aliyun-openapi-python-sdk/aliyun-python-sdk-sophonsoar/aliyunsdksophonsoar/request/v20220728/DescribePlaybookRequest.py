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

class DescribePlaybookRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'sophonsoar', '2022-07-28', 'DescribePlaybook')
		self.set_protocol_type('https')
		self.set_method('GET')

	def get_TaskflowMd5(self): # String
		return self.get_query_params().get('TaskflowMd5')

	def set_TaskflowMd5(self, TaskflowMd5):  # String
		self.add_query_param('TaskflowMd5', TaskflowMd5)
	def get_DebugFlag(self): # Integer
		return self.get_query_params().get('DebugFlag')

	def set_DebugFlag(self, DebugFlag):  # Integer
		self.add_query_param('DebugFlag', DebugFlag)
	def get_PlaybookUuid(self): # String
		return self.get_query_params().get('PlaybookUuid')

	def set_PlaybookUuid(self, PlaybookUuid):  # String
		self.add_query_param('PlaybookUuid', PlaybookUuid)
	def get_Lang(self): # String
		return self.get_query_params().get('Lang')

	def set_Lang(self, Lang):  # String
		self.add_query_param('Lang', Lang)
