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
from aliyunsdksddp.endpoint import endpoint_data

class CreateRuleRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Sddp', '2019-01-03', 'CreateRule','sddp')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_WarnLevel(self): # Integer
		return self.get_query_params().get('WarnLevel')

	def set_WarnLevel(self, WarnLevel):  # Integer
		self.add_query_param('WarnLevel', WarnLevel)
	def get_ProductCode(self): # String
		return self.get_query_params().get('ProductCode')

	def set_ProductCode(self, ProductCode):  # String
		self.add_query_param('ProductCode', ProductCode)
	def get_ProductId(self): # Long
		return self.get_query_params().get('ProductId')

	def set_ProductId(self, ProductId):  # Long
		self.add_query_param('ProductId', ProductId)
	def get_Description(self): # String
		return self.get_query_params().get('Description')

	def set_Description(self, Description):  # String
		self.add_query_param('Description', Description)
	def get_RiskLevelId(self): # Long
		return self.get_query_params().get('RiskLevelId')

	def set_RiskLevelId(self, RiskLevelId):  # Long
		self.add_query_param('RiskLevelId', RiskLevelId)
	def get_Content(self): # String
		return self.get_query_params().get('Content')

	def set_Content(self, Content):  # String
		self.add_query_param('Content', Content)
	def get_SourceIp(self): # String
		return self.get_query_params().get('SourceIp')

	def set_SourceIp(self, SourceIp):  # String
		self.add_query_param('SourceIp', SourceIp)
	def get_MatchType(self): # Integer
		return self.get_query_params().get('MatchType')

	def set_MatchType(self, MatchType):  # Integer
		self.add_query_param('MatchType', MatchType)
	def get_Lang(self): # String
		return self.get_query_params().get('Lang')

	def set_Lang(self, Lang):  # String
		self.add_query_param('Lang', Lang)
	def get_SupportForm(self): # Integer
		return self.get_query_params().get('SupportForm')

	def set_SupportForm(self, SupportForm):  # Integer
		self.add_query_param('SupportForm', SupportForm)
	def get_RuleType(self): # Integer
		return self.get_query_params().get('RuleType')

	def set_RuleType(self, RuleType):  # Integer
		self.add_query_param('RuleType', RuleType)
	def get_StatExpress(self): # String
		return self.get_query_params().get('StatExpress')

	def set_StatExpress(self, StatExpress):  # String
		self.add_query_param('StatExpress', StatExpress)
	def get_ContentCategory(self): # Integer
		return self.get_query_params().get('ContentCategory')

	def set_ContentCategory(self, ContentCategory):  # Integer
		self.add_query_param('ContentCategory', ContentCategory)
	def get_Target(self): # String
		return self.get_query_params().get('Target')

	def set_Target(self, Target):  # String
		self.add_query_param('Target', Target)
	def get_Name(self): # String
		return self.get_query_params().get('Name')

	def set_Name(self, Name):  # String
		self.add_query_param('Name', Name)
	def get_Category(self): # Integer
		return self.get_query_params().get('Category')

	def set_Category(self, Category):  # Integer
		self.add_query_param('Category', Category)
	def get_Status(self): # Integer
		return self.get_query_params().get('Status')

	def set_Status(self, Status):  # Integer
		self.add_query_param('Status', Status)
