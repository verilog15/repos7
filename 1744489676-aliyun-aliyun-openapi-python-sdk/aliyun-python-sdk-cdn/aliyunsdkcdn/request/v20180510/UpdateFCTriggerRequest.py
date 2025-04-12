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
from aliyunsdkcdn.endpoint import endpoint_data

class UpdateFCTriggerRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Cdn', '2018-05-10', 'UpdateFCTrigger')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_TriggerARN(self): # String
		return self.get_query_params().get('TriggerARN')

	def set_TriggerARN(self, TriggerARN):  # String
		self.add_query_param('TriggerARN', TriggerARN)
	def get_Notes(self): # String
		return self.get_body_params().get('Notes')

	def set_Notes(self, Notes):  # String
		self.add_body_params('Notes', Notes)
	def get_SourceARN(self): # String
		return self.get_body_params().get('SourceARN')

	def set_SourceARN(self, SourceARN):  # String
		self.add_body_params('SourceARN', SourceARN)
	def get_RoleARN(self): # String
		return self.get_body_params().get('RoleARN')

	def set_RoleARN(self, RoleARN):  # String
		self.add_body_params('RoleARN', RoleARN)
	def get_FunctionARN(self): # String
		return self.get_body_params().get('FunctionARN')

	def set_FunctionARN(self, FunctionARN):  # String
		self.add_body_params('FunctionARN', FunctionARN)
