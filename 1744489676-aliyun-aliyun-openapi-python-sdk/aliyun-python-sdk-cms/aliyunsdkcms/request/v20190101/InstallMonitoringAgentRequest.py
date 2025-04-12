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

class InstallMonitoringAgentRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Cms', '2019-01-01', 'InstallMonitoringAgent','cms')
		self.set_method('POST')

	def get_InstanceIdss(self): # RepeatList
		return self.get_query_params().get('InstanceIds')

	def set_InstanceIdss(self, InstanceIds):  # RepeatList
		for depth1 in range(len(InstanceIds)):
			self.add_query_param('InstanceIds.' + str(depth1 + 1), InstanceIds[depth1])
	def get_Force(self): # Boolean
		return self.get_query_params().get('Force')

	def set_Force(self, Force):  # Boolean
		self.add_query_param('Force', Force)
	def get_InstallCommand(self): # String
		return self.get_query_params().get('InstallCommand')

	def set_InstallCommand(self, InstallCommand):  # String
		self.add_query_param('InstallCommand', InstallCommand)
