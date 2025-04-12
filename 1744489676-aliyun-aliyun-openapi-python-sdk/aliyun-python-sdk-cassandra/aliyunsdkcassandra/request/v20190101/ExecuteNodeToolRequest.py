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
from aliyunsdkcassandra.endpoint import endpoint_data

class ExecuteNodeToolRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Cassandra', '2019-01-01', 'ExecuteNodeTool','Cassandra')
		self.set_method('POST')
		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())


	def get_ExecuteNodes(self):
		return self.get_query_params().get('ExecuteNodes')

	def set_ExecuteNodes(self,ExecuteNodes):
		self.add_query_param('ExecuteNodes',ExecuteNodes)

	def get_DataCenterId(self):
		return self.get_query_params().get('DataCenterId')

	def set_DataCenterId(self,DataCenterId):
		self.add_query_param('DataCenterId',DataCenterId)

	def get_ClusterId(self):
		return self.get_query_params().get('ClusterId')

	def set_ClusterId(self,ClusterId):
		self.add_query_param('ClusterId',ClusterId)

	def get_Command(self):
		return self.get_query_params().get('Command')

	def set_Command(self,Command):
		self.add_query_param('Command',Command)

	def get_Arguments(self):
		return self.get_query_params().get('Arguments')

	def set_Arguments(self,Arguments):
		self.add_query_param('Arguments',Arguments)