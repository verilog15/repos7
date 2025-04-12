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

class DescribeIMRobotsRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'ARMS', '2019-08-08', 'DescribeIMRobots','arms')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_RobotIds(self): # String
		return self.get_query_params().get('RobotIds')

	def set_RobotIds(self, RobotIds):  # String
		self.add_query_param('RobotIds', RobotIds)
	def get_RobotName(self): # String
		return self.get_query_params().get('RobotName')

	def set_RobotName(self, RobotName):  # String
		self.add_query_param('RobotName', RobotName)
	def get_Size(self): # Long
		return self.get_query_params().get('Size')

	def set_Size(self, Size):  # Long
		self.add_query_param('Size', Size)
	def get_Page(self): # Long
		return self.get_query_params().get('Page')

	def set_Page(self, Page):  # Long
		self.add_query_param('Page', Page)
