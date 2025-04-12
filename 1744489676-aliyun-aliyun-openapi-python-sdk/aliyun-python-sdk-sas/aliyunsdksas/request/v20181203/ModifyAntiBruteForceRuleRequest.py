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
from aliyunsdksas.endpoint import endpoint_data

class ModifyAntiBruteForceRuleRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Sas', '2018-12-03', 'ModifyAntiBruteForceRule','sas')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_ResourceOwnerId(self): # Long
		return self.get_query_params().get('ResourceOwnerId')

	def set_ResourceOwnerId(self, ResourceOwnerId):  # Long
		self.add_query_param('ResourceOwnerId', ResourceOwnerId)
	def get_ForbiddenTime(self): # Integer
		return self.get_query_params().get('ForbiddenTime')

	def set_ForbiddenTime(self, ForbiddenTime):  # Integer
		self.add_query_param('ForbiddenTime', ForbiddenTime)
	def get_FailCount(self): # Integer
		return self.get_query_params().get('FailCount')

	def set_FailCount(self, FailCount):  # Integer
		self.add_query_param('FailCount', FailCount)
	def get_SourceIp(self): # String
		return self.get_query_params().get('SourceIp')

	def set_SourceIp(self, SourceIp):  # String
		self.add_query_param('SourceIp', SourceIp)
	def get_UuidLists(self): # RepeatList
		return self.get_query_params().get('UuidList')

	def set_UuidLists(self, UuidList):  # RepeatList
		for depth1 in range(len(UuidList)):
			self.add_query_param('UuidList.' + str(depth1 + 1), UuidList[depth1])
	def get_Id(self): # Long
		return self.get_query_params().get('Id')

	def set_Id(self, Id):  # Long
		self.add_query_param('Id', Id)
	def get_Name(self): # String
		return self.get_query_params().get('Name')

	def set_Name(self, Name):  # String
		self.add_query_param('Name', Name)
	def get_Span(self): # Integer
		return self.get_query_params().get('Span')

	def set_Span(self, Span):  # Integer
		self.add_query_param('Span', Span)
	def get_DefaultRule(self): # Boolean
		return self.get_query_params().get('DefaultRule')

	def set_DefaultRule(self, DefaultRule):  # Boolean
		self.add_query_param('DefaultRule', DefaultRule)
