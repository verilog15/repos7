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

class PutMetricRuleTargetsRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Cms', '2019-01-01', 'PutMetricRuleTargets','cms')
		self.set_method('POST')

	def get_Targetss(self): # RepeatList
		return self.get_query_params().get('Targets')

	def set_Targetss(self, Targets):  # RepeatList
		for depth1 in range(len(Targets)):
			if Targets[depth1].get('Level') is not None:
				self.add_query_param('Targets.' + str(depth1 + 1) + '.Level', Targets[depth1].get('Level'))
			if Targets[depth1].get('Id') is not None:
				self.add_query_param('Targets.' + str(depth1 + 1) + '.Id', Targets[depth1].get('Id'))
			if Targets[depth1].get('Arn') is not None:
				self.add_query_param('Targets.' + str(depth1 + 1) + '.Arn', Targets[depth1].get('Arn'))
			if Targets[depth1].get('JsonParams') is not None:
				self.add_query_param('Targets.' + str(depth1 + 1) + '.JsonParams', Targets[depth1].get('JsonParams'))
	def get_RuleId(self): # String
		return self.get_query_params().get('RuleId')

	def set_RuleId(self, RuleId):  # String
		self.add_query_param('RuleId', RuleId)
