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

class CreateMonitorGroupInstancesRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Cms', '2019-01-01', 'CreateMonitorGroupInstances','cms')
		self.set_method('POST')

	def get_Instancess(self): # RepeatList
		return self.get_query_params().get('Instances')

	def set_Instancess(self, Instances):  # RepeatList
		for depth1 in range(len(Instances)):
			if Instances[depth1].get('InstanceName') is not None:
				self.add_query_param('Instances.' + str(depth1 + 1) + '.InstanceName', Instances[depth1].get('InstanceName'))
			if Instances[depth1].get('InstanceId') is not None:
				self.add_query_param('Instances.' + str(depth1 + 1) + '.InstanceId', Instances[depth1].get('InstanceId'))
			if Instances[depth1].get('RegionId') is not None:
				self.add_query_param('Instances.' + str(depth1 + 1) + '.RegionId', Instances[depth1].get('RegionId'))
			if Instances[depth1].get('Category') is not None:
				self.add_query_param('Instances.' + str(depth1 + 1) + '.Category', Instances[depth1].get('Category'))
	def get_GroupId(self): # String
		return self.get_query_params().get('GroupId')

	def set_GroupId(self, GroupId):  # String
		self.add_query_param('GroupId', GroupId)
