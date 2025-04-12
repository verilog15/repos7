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
from aliyunsdkros.endpoint import endpoint_data

class CreateChangeSetRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'ROS', '2019-09-10', 'CreateChangeSet','ros')
		self.set_method('POST')
		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())


	def get_TimeoutInMinutes(self):
		return self.get_query_params().get('TimeoutInMinutes')

	def set_TimeoutInMinutes(self,TimeoutInMinutes):
		self.add_query_param('TimeoutInMinutes',TimeoutInMinutes)

	def get_StackPolicyDuringUpdateBody(self):
		return self.get_query_params().get('StackPolicyDuringUpdateBody')

	def set_StackPolicyDuringUpdateBody(self,StackPolicyDuringUpdateBody):
		self.add_query_param('StackPolicyDuringUpdateBody',StackPolicyDuringUpdateBody)

	def get_TemplateVersion(self):
		return self.get_query_params().get('TemplateVersion')

	def set_TemplateVersion(self,TemplateVersion):
		self.add_query_param('TemplateVersion',TemplateVersion)

	def get_StackName(self):
		return self.get_query_params().get('StackName')

	def set_StackName(self,StackName):
		self.add_query_param('StackName',StackName)

	def get_ChangeSetType(self):
		return self.get_query_params().get('ChangeSetType')

	def set_ChangeSetType(self,ChangeSetType):
		self.add_query_param('ChangeSetType',ChangeSetType)

	def get_DisableRollback(self):
		return self.get_query_params().get('DisableRollback')

	def set_DisableRollback(self,DisableRollback):
		self.add_query_param('DisableRollback',DisableRollback)

	def get_TemplateId(self):
		return self.get_query_params().get('TemplateId')

	def set_TemplateId(self,TemplateId):
		self.add_query_param('TemplateId',TemplateId)

	def get_Parameters(self):
		return self.get_query_params().get('Parameters')

	def set_Parameters(self, Parameterss):
		for depth1 in range(len(Parameterss)):
			if Parameterss[depth1].get('ParameterValue') is not None:
				self.add_query_param('Parameters.' + str(depth1 + 1) + '.ParameterValue', Parameterss[depth1].get('ParameterValue'))
			if Parameterss[depth1].get('ParameterKey') is not None:
				self.add_query_param('Parameters.' + str(depth1 + 1) + '.ParameterKey', Parameterss[depth1].get('ParameterKey'))

	def get_ClientToken(self):
		return self.get_query_params().get('ClientToken')

	def set_ClientToken(self,ClientToken):
		self.add_query_param('ClientToken',ClientToken)

	def get_TemplateBody(self):
		return self.get_query_params().get('TemplateBody')

	def set_TemplateBody(self,TemplateBody):
		self.add_query_param('TemplateBody',TemplateBody)

	def get_StackId(self):
		return self.get_query_params().get('StackId')

	def set_StackId(self,StackId):
		self.add_query_param('StackId',StackId)

	def get_Description(self):
		return self.get_query_params().get('Description')

	def set_Description(self,Description):
		self.add_query_param('Description',Description)

	def get_TemplateURL(self):
		return self.get_query_params().get('TemplateURL')

	def set_TemplateURL(self,TemplateURL):
		self.add_query_param('TemplateURL',TemplateURL)

	def get_NotificationURLs(self):
		return self.get_query_params().get('NotificationURLs')

	def set_NotificationURLs(self, NotificationURLss):
		for depth1 in range(len(NotificationURLss)):
			if NotificationURLss[depth1] is not None:
				self.add_query_param('NotificationURLs.' + str(depth1 + 1) , NotificationURLss[depth1])

	def get_ResourcesToImport(self):
		return self.get_query_params().get('ResourcesToImport')

	def set_ResourcesToImport(self, ResourcesToImports):
		for depth1 in range(len(ResourcesToImports)):
			if ResourcesToImports[depth1].get('ResourceIdentifier') is not None:
				self.add_query_param('ResourcesToImport.' + str(depth1 + 1) + '.ResourceIdentifier', ResourcesToImports[depth1].get('ResourceIdentifier'))
			if ResourcesToImports[depth1].get('LogicalResourceId') is not None:
				self.add_query_param('ResourcesToImport.' + str(depth1 + 1) + '.LogicalResourceId', ResourcesToImports[depth1].get('LogicalResourceId'))
			if ResourcesToImports[depth1].get('ResourceType') is not None:
				self.add_query_param('ResourcesToImport.' + str(depth1 + 1) + '.ResourceType', ResourcesToImports[depth1].get('ResourceType'))

	def get_StackPolicyBody(self):
		return self.get_query_params().get('StackPolicyBody')

	def set_StackPolicyBody(self,StackPolicyBody):
		self.add_query_param('StackPolicyBody',StackPolicyBody)

	def get_StackPolicyDuringUpdateURL(self):
		return self.get_query_params().get('StackPolicyDuringUpdateURL')

	def set_StackPolicyDuringUpdateURL(self,StackPolicyDuringUpdateURL):
		self.add_query_param('StackPolicyDuringUpdateURL',StackPolicyDuringUpdateURL)

	def get_RamRoleName(self):
		return self.get_query_params().get('RamRoleName')

	def set_RamRoleName(self,RamRoleName):
		self.add_query_param('RamRoleName',RamRoleName)

	def get_UsePreviousParameters(self):
		return self.get_query_params().get('UsePreviousParameters')

	def set_UsePreviousParameters(self,UsePreviousParameters):
		self.add_query_param('UsePreviousParameters',UsePreviousParameters)

	def get_ReplacementOption(self):
		return self.get_query_params().get('ReplacementOption')

	def set_ReplacementOption(self,ReplacementOption):
		self.add_query_param('ReplacementOption',ReplacementOption)

	def get_StackPolicyURL(self):
		return self.get_query_params().get('StackPolicyURL')

	def set_StackPolicyURL(self,StackPolicyURL):
		self.add_query_param('StackPolicyURL',StackPolicyURL)

	def get_ChangeSetName(self):
		return self.get_query_params().get('ChangeSetName')

	def set_ChangeSetName(self,ChangeSetName):
		self.add_query_param('ChangeSetName',ChangeSetName)