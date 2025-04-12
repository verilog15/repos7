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
from aliyunsdkccc.endpoint import endpoint_data

class AddPhoneNumbersRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'CCC', '2020-07-01', 'AddPhoneNumbers','CCC')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_ContactFlowId(self): # String
		return self.get_query_params().get('ContactFlowId')

	def set_ContactFlowId(self, ContactFlowId):  # String
		self.add_query_param('ContactFlowId', ContactFlowId)
	def get_Usage(self): # String
		return self.get_query_params().get('Usage')

	def set_Usage(self, Usage):  # String
		self.add_query_param('Usage', Usage)
	def get_NumberGroupId(self): # String
		return self.get_query_params().get('NumberGroupId')

	def set_NumberGroupId(self, NumberGroupId):  # String
		self.add_query_param('NumberGroupId', NumberGroupId)
	def get_NumberList(self): # String
		return self.get_query_params().get('NumberList')

	def set_NumberList(self, NumberList):  # String
		self.add_query_param('NumberList', NumberList)
	def get_InstanceId(self): # String
		return self.get_query_params().get('InstanceId')

	def set_InstanceId(self, InstanceId):  # String
		self.add_query_param('InstanceId', InstanceId)
