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
from aliyunsdkconfig.endpoint import endpoint_data

class UpdateConfigRuleRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Config', '2020-09-07', 'UpdateConfigRule','config')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_ConfigRuleId(self): # String
		return self.get_body_params().get('ConfigRuleId')

	def set_ConfigRuleId(self, ConfigRuleId):  # String
		self.add_body_params('ConfigRuleId', ConfigRuleId)
	def get_TagKeyScope(self): # String
		return self.get_body_params().get('TagKeyScope')

	def set_TagKeyScope(self, TagKeyScope):  # String
		self.add_body_params('TagKeyScope', TagKeyScope)
	def get_ClientToken(self): # String
		return self.get_body_params().get('ClientToken')

	def set_ClientToken(self, ClientToken):  # String
		self.add_body_params('ClientToken', ClientToken)
	def get_ResourceTypesScope(self): # Array
		return self.get_body_params().get('ResourceTypesScope')

	def set_ResourceTypesScope(self, ResourceTypesScope):  # Array
		for index1, value1 in enumerate(ResourceTypesScope):
			self.add_body_params('ResourceTypesScope.' + str(index1 + 1), value1)
	def get_Description(self): # String
		return self.get_body_params().get('Description')

	def set_Description(self, Description):  # String
		self.add_body_params('Description', Description)
	def get_ExcludeResourceGroupIdsScope(self): # String
		return self.get_body_params().get('ExcludeResourceGroupIdsScope')

	def set_ExcludeResourceGroupIdsScope(self, ExcludeResourceGroupIdsScope):  # String
		self.add_body_params('ExcludeResourceGroupIdsScope', ExcludeResourceGroupIdsScope)
	def get_ConfigRuleTriggerTypes(self): # String
		return self.get_body_params().get('ConfigRuleTriggerTypes')

	def set_ConfigRuleTriggerTypes(self, ConfigRuleTriggerTypes):  # String
		self.add_body_params('ConfigRuleTriggerTypes', ConfigRuleTriggerTypes)
	def get_TagValueScope(self): # String
		return self.get_body_params().get('TagValueScope')

	def set_TagValueScope(self, TagValueScope):  # String
		self.add_body_params('TagValueScope', TagValueScope)
	def get_RegionIdsScope(self): # String
		return self.get_body_params().get('RegionIdsScope')

	def set_RegionIdsScope(self, RegionIdsScope):  # String
		self.add_body_params('RegionIdsScope', RegionIdsScope)
	def get_ResourceIdsScope(self): # String
		return self.get_body_params().get('ResourceIdsScope')

	def set_ResourceIdsScope(self, ResourceIdsScope):  # String
		self.add_body_params('ResourceIdsScope', ResourceIdsScope)
	def get_ExcludeTagsScope(self): # Array
		return self.get_body_params().get('ExcludeTagsScope')

	def set_ExcludeTagsScope(self, ExcludeTagsScope):  # Array
		for index1, value1 in enumerate(ExcludeTagsScope):
			if value1.get('TagValue') is not None:
				self.add_body_params('ExcludeTagsScope.' + str(index1 + 1) + '.TagValue', value1.get('TagValue'))
			if value1.get('TagKey') is not None:
				self.add_body_params('ExcludeTagsScope.' + str(index1 + 1) + '.TagKey', value1.get('TagKey'))
	def get_RiskLevel(self): # Integer
		return self.get_body_params().get('RiskLevel')

	def set_RiskLevel(self, RiskLevel):  # Integer
		self.add_body_params('RiskLevel', RiskLevel)
	def get_TagsScope(self): # Array
		return self.get_body_params().get('TagsScope')

	def set_TagsScope(self, TagsScope):  # Array
		for index1, value1 in enumerate(TagsScope):
			if value1.get('TagValue') is not None:
				self.add_body_params('TagsScope.' + str(index1 + 1) + '.TagValue', value1.get('TagValue'))
			if value1.get('TagKey') is not None:
				self.add_body_params('TagsScope.' + str(index1 + 1) + '.TagKey', value1.get('TagKey'))
	def get_ResourceGroupIdsScope(self): # String
		return self.get_body_params().get('ResourceGroupIdsScope')

	def set_ResourceGroupIdsScope(self, ResourceGroupIdsScope):  # String
		self.add_body_params('ResourceGroupIdsScope', ResourceGroupIdsScope)
	def get_InputParameters(self): # String
		return self.get_body_params().get('InputParameters')

	def set_InputParameters(self, InputParameters):  # String
		self.add_body_params('InputParameters', InputParameters)
	def get_ExcludeRegionIdsScope(self): # String
		return self.get_body_params().get('ExcludeRegionIdsScope')

	def set_ExcludeRegionIdsScope(self, ExcludeRegionIdsScope):  # String
		self.add_body_params('ExcludeRegionIdsScope', ExcludeRegionIdsScope)
	def get_TagKeyLogicScope(self): # String
		return self.get_body_params().get('TagKeyLogicScope')

	def set_TagKeyLogicScope(self, TagKeyLogicScope):  # String
		self.add_body_params('TagKeyLogicScope', TagKeyLogicScope)
	def get_ConfigRuleName(self): # String
		return self.get_body_params().get('ConfigRuleName')

	def set_ConfigRuleName(self, ConfigRuleName):  # String
		self.add_body_params('ConfigRuleName', ConfigRuleName)
	def get_MaximumExecutionFrequency(self): # String
		return self.get_body_params().get('MaximumExecutionFrequency')

	def set_MaximumExecutionFrequency(self, MaximumExecutionFrequency):  # String
		self.add_body_params('MaximumExecutionFrequency', MaximumExecutionFrequency)
	def get_ExcludeResourceIdsScope(self): # String
		return self.get_body_params().get('ExcludeResourceIdsScope')

	def set_ExcludeResourceIdsScope(self, ExcludeResourceIdsScope):  # String
		self.add_body_params('ExcludeResourceIdsScope', ExcludeResourceIdsScope)
