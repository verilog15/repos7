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

class ListCallDetailRecordsRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'CCC', '2020-07-01', 'ListCallDetailRecords','CCC')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_ContactId(self): # String
		return self.get_query_params().get('ContactId')

	def set_ContactId(self, ContactId):  # String
		self.add_query_param('ContactId', ContactId)
	def get_Criteria(self): # String
		return self.get_query_params().get('Criteria')

	def set_Criteria(self, Criteria):  # String
		self.add_query_param('Criteria', Criteria)
	def get_ContactDispositionList(self): # String
		return self.get_query_params().get('ContactDispositionList')

	def set_ContactDispositionList(self, ContactDispositionList):  # String
		self.add_query_param('ContactDispositionList', ContactDispositionList)
	def get_OrderByField(self): # String
		return self.get_query_params().get('OrderByField')

	def set_OrderByField(self, OrderByField):  # String
		self.add_query_param('OrderByField', OrderByField)
	def get_StartTime(self): # Long
		return self.get_query_params().get('StartTime')

	def set_StartTime(self, StartTime):  # Long
		self.add_query_param('StartTime', StartTime)
	def get_PageNumber(self): # Integer
		return self.get_query_params().get('PageNumber')

	def set_PageNumber(self, PageNumber):  # Integer
		self.add_query_param('PageNumber', PageNumber)
	def get_EarlyMediaStateList(self): # String
		return self.get_query_params().get('EarlyMediaStateList')

	def set_EarlyMediaStateList(self, EarlyMediaStateList):  # String
		self.add_query_param('EarlyMediaStateList', EarlyMediaStateList)
	def get_CalledNumber(self): # String
		return self.get_query_params().get('CalledNumber')

	def set_CalledNumber(self, CalledNumber):  # String
		self.add_query_param('CalledNumber', CalledNumber)
	def get_SatisfactionList(self): # String
		return self.get_query_params().get('SatisfactionList')

	def set_SatisfactionList(self, SatisfactionList):  # String
		self.add_query_param('SatisfactionList', SatisfactionList)
	def get_PageSize(self): # Integer
		return self.get_query_params().get('PageSize')

	def set_PageSize(self, PageSize):  # Integer
		self.add_query_param('PageSize', PageSize)
	def get_SortOrder(self): # String
		return self.get_query_params().get('SortOrder')

	def set_SortOrder(self, SortOrder):  # String
		self.add_query_param('SortOrder', SortOrder)
	def get_SatisfactionDescriptionList(self): # String
		return self.get_query_params().get('SatisfactionDescriptionList')

	def set_SatisfactionDescriptionList(self, SatisfactionDescriptionList):  # String
		self.add_query_param('SatisfactionDescriptionList', SatisfactionDescriptionList)
	def get_AgentId(self): # String
		return self.get_query_params().get('AgentId')

	def set_AgentId(self, AgentId):  # String
		self.add_query_param('AgentId', AgentId)
	def get_ContactType(self): # String
		return self.get_query_params().get('ContactType')

	def set_ContactType(self, ContactType):  # String
		self.add_query_param('ContactType', ContactType)
	def get_ContactTypeList(self): # String
		return self.get_query_params().get('ContactTypeList')

	def set_ContactTypeList(self, ContactTypeList):  # String
		self.add_query_param('ContactTypeList', ContactTypeList)
	def get_SatisfactionSurveyChannel(self): # String
		return self.get_query_params().get('SatisfactionSurveyChannel')

	def set_SatisfactionSurveyChannel(self, SatisfactionSurveyChannel):  # String
		self.add_query_param('SatisfactionSurveyChannel', SatisfactionSurveyChannel)
	def get_EndTime(self): # Long
		return self.get_query_params().get('EndTime')

	def set_EndTime(self, EndTime):  # Long
		self.add_query_param('EndTime', EndTime)
	def get_CallingNumber(self): # String
		return self.get_query_params().get('CallingNumber')

	def set_CallingNumber(self, CallingNumber):  # String
		self.add_query_param('CallingNumber', CallingNumber)
	def get_ContactDisposition(self): # String
		return self.get_query_params().get('ContactDisposition')

	def set_ContactDisposition(self, ContactDisposition):  # String
		self.add_query_param('ContactDisposition', ContactDisposition)
	def get_InstanceId(self): # String
		return self.get_query_params().get('InstanceId')

	def set_InstanceId(self, InstanceId):  # String
		self.add_query_param('InstanceId', InstanceId)
	def get_SkillGroupId(self): # String
		return self.get_query_params().get('SkillGroupId')

	def set_SkillGroupId(self, SkillGroupId):  # String
		self.add_query_param('SkillGroupId', SkillGroupId)
