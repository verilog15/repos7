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

class ModifyMetricRuleTemplateRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Cms', '2019-01-01', 'ModifyMetricRuleTemplate','cms')
		self.set_method('POST')

	def get_RestVersion(self): # Long
		return self.get_query_params().get('RestVersion')

	def set_RestVersion(self, RestVersion):  # Long
		self.add_query_param('RestVersion', RestVersion)
	def get_Description(self): # String
		return self.get_query_params().get('Description')

	def set_Description(self, Description):  # String
		self.add_query_param('Description', Description)
	def get_TemplateId(self): # Long
		return self.get_query_params().get('TemplateId')

	def set_TemplateId(self, TemplateId):  # Long
		self.add_query_param('TemplateId', TemplateId)
	def get_Name(self): # String
		return self.get_query_params().get('Name')

	def set_Name(self, Name):  # String
		self.add_query_param('Name', Name)
	def get_AlertTemplatess(self): # RepeatList
		return self.get_query_params().get('AlertTemplates')

	def set_AlertTemplatess(self, AlertTemplates):  # RepeatList
		for depth1 in range(len(AlertTemplates)):
			if AlertTemplates[depth1].get('Escalations.Warn.Threshold') is not None:
				self.add_query_param('AlertTemplates.' + str(depth1 + 1) + '.Escalations.Warn.Threshold', AlertTemplates[depth1].get('Escalations.Warn.Threshold'))
			if AlertTemplates[depth1].get('Period') is not None:
				self.add_query_param('AlertTemplates.' + str(depth1 + 1) + '.Period', AlertTemplates[depth1].get('Period'))
			if AlertTemplates[depth1].get('Escalations.Info.N') is not None:
				self.add_query_param('AlertTemplates.' + str(depth1 + 1) + '.Escalations.Info.N', AlertTemplates[depth1].get('Escalations.Info.N'))
			if AlertTemplates[depth1].get('Webhook') is not None:
				self.add_query_param('AlertTemplates.' + str(depth1 + 1) + '.Webhook', AlertTemplates[depth1].get('Webhook'))
			if AlertTemplates[depth1].get('Escalations.Warn.ComparisonOperator') is not None:
				self.add_query_param('AlertTemplates.' + str(depth1 + 1) + '.Escalations.Warn.ComparisonOperator', AlertTemplates[depth1].get('Escalations.Warn.ComparisonOperator'))
			if AlertTemplates[depth1].get('Escalations.Critical.Statistics') is not None:
				self.add_query_param('AlertTemplates.' + str(depth1 + 1) + '.Escalations.Critical.Statistics', AlertTemplates[depth1].get('Escalations.Critical.Statistics'))
			if AlertTemplates[depth1].get('Escalations.Info.Times') is not None:
				self.add_query_param('AlertTemplates.' + str(depth1 + 1) + '.Escalations.Info.Times', AlertTemplates[depth1].get('Escalations.Info.Times'))
			if AlertTemplates[depth1].get('RuleName') is not None:
				self.add_query_param('AlertTemplates.' + str(depth1 + 1) + '.RuleName', AlertTemplates[depth1].get('RuleName'))
			if AlertTemplates[depth1].get('Escalations.Info.Statistics') is not None:
				self.add_query_param('AlertTemplates.' + str(depth1 + 1) + '.Escalations.Info.Statistics', AlertTemplates[depth1].get('Escalations.Info.Statistics'))
			if AlertTemplates[depth1].get('Escalations.Critical.Times') is not None:
				self.add_query_param('AlertTemplates.' + str(depth1 + 1) + '.Escalations.Critical.Times', AlertTemplates[depth1].get('Escalations.Critical.Times'))
			if AlertTemplates[depth1].get('Escalations.Info.ComparisonOperator') is not None:
				self.add_query_param('AlertTemplates.' + str(depth1 + 1) + '.Escalations.Info.ComparisonOperator', AlertTemplates[depth1].get('Escalations.Info.ComparisonOperator'))
			if AlertTemplates[depth1].get('Escalations.Info.Threshold') is not None:
				self.add_query_param('AlertTemplates.' + str(depth1 + 1) + '.Escalations.Info.Threshold', AlertTemplates[depth1].get('Escalations.Info.Threshold'))
			if AlertTemplates[depth1].get('Escalations.Warn.Statistics') is not None:
				self.add_query_param('AlertTemplates.' + str(depth1 + 1) + '.Escalations.Warn.Statistics', AlertTemplates[depth1].get('Escalations.Warn.Statistics'))
			if AlertTemplates[depth1].get('Namespace') is not None:
				self.add_query_param('AlertTemplates.' + str(depth1 + 1) + '.Namespace', AlertTemplates[depth1].get('Namespace'))
			if AlertTemplates[depth1].get('Escalations.Warn.N') is not None:
				self.add_query_param('AlertTemplates.' + str(depth1 + 1) + '.Escalations.Warn.N', AlertTemplates[depth1].get('Escalations.Warn.N'))
			if AlertTemplates[depth1].get('Escalations.Critical.N') is not None:
				self.add_query_param('AlertTemplates.' + str(depth1 + 1) + '.Escalations.Critical.N', AlertTemplates[depth1].get('Escalations.Critical.N'))
			if AlertTemplates[depth1].get('Selector') is not None:
				self.add_query_param('AlertTemplates.' + str(depth1 + 1) + '.Selector', AlertTemplates[depth1].get('Selector'))
			if AlertTemplates[depth1].get('MetricName') is not None:
				self.add_query_param('AlertTemplates.' + str(depth1 + 1) + '.MetricName', AlertTemplates[depth1].get('MetricName'))
			if AlertTemplates[depth1].get('Escalations.Warn.Times') is not None:
				self.add_query_param('AlertTemplates.' + str(depth1 + 1) + '.Escalations.Warn.Times', AlertTemplates[depth1].get('Escalations.Warn.Times'))
			if AlertTemplates[depth1].get('Category') is not None:
				self.add_query_param('AlertTemplates.' + str(depth1 + 1) + '.Category', AlertTemplates[depth1].get('Category'))
			if AlertTemplates[depth1].get('Escalations.Critical.ComparisonOperator') is not None:
				self.add_query_param('AlertTemplates.' + str(depth1 + 1) + '.Escalations.Critical.ComparisonOperator', AlertTemplates[depth1].get('Escalations.Critical.ComparisonOperator'))
			if AlertTemplates[depth1].get('Escalations.Critical.Threshold') is not None:
				self.add_query_param('AlertTemplates.' + str(depth1 + 1) + '.Escalations.Critical.Threshold', AlertTemplates[depth1].get('Escalations.Critical.Threshold'))
