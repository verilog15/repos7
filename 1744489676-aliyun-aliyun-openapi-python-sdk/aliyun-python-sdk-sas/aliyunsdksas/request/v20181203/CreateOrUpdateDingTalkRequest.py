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

class CreateOrUpdateDingTalkRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Sas', '2018-12-03', 'CreateOrUpdateDingTalk','sas')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_RuleActionName(self): # String
		return self.get_query_params().get('RuleActionName')

	def set_RuleActionName(self, RuleActionName):  # String
		self.add_query_param('RuleActionName', RuleActionName)
	def get_GroupIdList(self): # String
		return self.get_query_params().get('GroupIdList')

	def set_GroupIdList(self, GroupIdList):  # String
		self.add_query_param('GroupIdList', GroupIdList)
	def get_Id(self): # Long
		return self.get_query_params().get('Id')

	def set_Id(self, Id):  # Long
		self.add_query_param('Id', Id)
	def get_SendUrl(self): # String
		return self.get_query_params().get('SendUrl')

	def set_SendUrl(self, SendUrl):  # String
		self.add_query_param('SendUrl', SendUrl)
	def get_IntervalTime(self): # Long
		return self.get_query_params().get('IntervalTime')

	def set_IntervalTime(self, IntervalTime):  # Long
		self.add_query_param('IntervalTime', IntervalTime)
	def get_DingTalkLang(self): # String
		return self.get_query_params().get('DingTalkLang')

	def set_DingTalkLang(self, DingTalkLang):  # String
		self.add_query_param('DingTalkLang', DingTalkLang)
	def get_ConfigList(self): # String
		return self.get_query_params().get('ConfigList')

	def set_ConfigList(self, ConfigList):  # String
		self.add_query_param('ConfigList', ConfigList)
