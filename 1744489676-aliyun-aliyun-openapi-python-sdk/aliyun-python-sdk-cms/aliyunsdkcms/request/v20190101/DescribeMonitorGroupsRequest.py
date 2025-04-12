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

class DescribeMonitorGroupsRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Cms', '2019-01-01', 'DescribeMonitorGroups','cms')
		self.set_method('POST')

	def get_SelectContactGroups(self): # Boolean
		return self.get_query_params().get('SelectContactGroups')

	def set_SelectContactGroups(self, SelectContactGroups):  # Boolean
		self.add_query_param('SelectContactGroups', SelectContactGroups)
	def get_IncludeTemplateHistory(self): # Boolean
		return self.get_query_params().get('IncludeTemplateHistory')

	def set_IncludeTemplateHistory(self, IncludeTemplateHistory):  # Boolean
		self.add_query_param('IncludeTemplateHistory', IncludeTemplateHistory)
	def get_DynamicTagRuleId(self): # String
		return self.get_query_params().get('DynamicTagRuleId')

	def set_DynamicTagRuleId(self, DynamicTagRuleId):  # String
		self.add_query_param('DynamicTagRuleId', DynamicTagRuleId)
	def get_Type(self): # String
		return self.get_query_params().get('Type')

	def set_Type(self, Type):  # String
		self.add_query_param('Type', Type)
	def get_PageNumber(self): # Integer
		return self.get_query_params().get('PageNumber')

	def set_PageNumber(self, PageNumber):  # Integer
		self.add_query_param('PageNumber', PageNumber)
	def get_GroupFounderTagKey(self): # String
		return self.get_query_params().get('GroupFounderTagKey')

	def set_GroupFounderTagKey(self, GroupFounderTagKey):  # String
		self.add_query_param('GroupFounderTagKey', GroupFounderTagKey)
	def get_PageSize(self): # Integer
		return self.get_query_params().get('PageSize')

	def set_PageSize(self, PageSize):  # Integer
		self.add_query_param('PageSize', PageSize)
	def get_GroupFounderTagValue(self): # String
		return self.get_query_params().get('GroupFounderTagValue')

	def set_GroupFounderTagValue(self, GroupFounderTagValue):  # String
		self.add_query_param('GroupFounderTagValue', GroupFounderTagValue)
	def get_Tags(self): # RepeatList
		return self.get_query_params().get('Tag')

	def set_Tags(self, Tag):  # RepeatList
		for depth1 in range(len(Tag)):
			if Tag[depth1].get('Value') is not None:
				self.add_query_param('Tag.' + str(depth1 + 1) + '.Value', Tag[depth1].get('Value'))
			if Tag[depth1].get('Key') is not None:
				self.add_query_param('Tag.' + str(depth1 + 1) + '.Key', Tag[depth1].get('Key'))
	def get_Keyword(self): # String
		return self.get_query_params().get('Keyword')

	def set_Keyword(self, Keyword):  # String
		self.add_query_param('Keyword', Keyword)
	def get_Types(self): # String
		return self.get_query_params().get('Types')

	def set_Types(self, Types):  # String
		self.add_query_param('Types', Types)
	def get_GroupId(self): # String
		return self.get_query_params().get('GroupId')

	def set_GroupId(self, GroupId):  # String
		self.add_query_param('GroupId', GroupId)
	def get_GroupName(self): # String
		return self.get_query_params().get('GroupName')

	def set_GroupName(self, GroupName):  # String
		self.add_query_param('GroupName', GroupName)
	def get_InstanceId(self): # String
		return self.get_query_params().get('InstanceId')

	def set_InstanceId(self, InstanceId):  # String
		self.add_query_param('InstanceId', InstanceId)
