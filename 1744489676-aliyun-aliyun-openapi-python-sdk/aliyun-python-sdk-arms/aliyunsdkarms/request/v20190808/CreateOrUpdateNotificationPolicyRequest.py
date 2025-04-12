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
from aliyunsdkarms.endpoint import endpoint_data

class CreateOrUpdateNotificationPolicyRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'ARMS', '2019-08-08', 'CreateOrUpdateNotificationPolicy','arms')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_IntegrationId(self): # Long
		return self.get_body_params().get('IntegrationId')

	def set_IntegrationId(self, IntegrationId):  # Long
		self.add_body_params('IntegrationId', IntegrationId)
	def get_GroupRule(self): # String
		return self.get_body_params().get('GroupRule')

	def set_GroupRule(self, GroupRule):  # String
		self.add_body_params('GroupRule', GroupRule)
	def get_Repeat(self): # Boolean
		return self.get_body_params().get('Repeat')

	def set_Repeat(self, Repeat):  # Boolean
		self.add_body_params('Repeat', Repeat)
	def get_Id(self): # Long
		return self.get_body_params().get('Id')

	def set_Id(self, Id):  # Long
		self.add_body_params('Id', Id)
	def get_NotifyRule(self): # String
		return self.get_body_params().get('NotifyRule')

	def set_NotifyRule(self, NotifyRule):  # String
		self.add_body_params('NotifyRule', NotifyRule)
	def get_State(self): # String
		return self.get_body_params().get('State')

	def set_State(self, State):  # String
		self.add_body_params('State', State)
	def get_RepeatInterval(self): # Long
		return self.get_body_params().get('RepeatInterval')

	def set_RepeatInterval(self, RepeatInterval):  # Long
		self.add_body_params('RepeatInterval', RepeatInterval)
	def get_EscalationPolicyId(self): # Long
		return self.get_body_params().get('EscalationPolicyId')

	def set_EscalationPolicyId(self, EscalationPolicyId):  # Long
		self.add_body_params('EscalationPolicyId', EscalationPolicyId)
	def get_SendRecoverMessage(self): # Boolean
		return self.get_body_params().get('SendRecoverMessage')

	def set_SendRecoverMessage(self, SendRecoverMessage):  # Boolean
		self.add_body_params('SendRecoverMessage', SendRecoverMessage)
	def get_MatchingRules(self): # String
		return self.get_body_params().get('MatchingRules')

	def set_MatchingRules(self, MatchingRules):  # String
		self.add_body_params('MatchingRules', MatchingRules)
	def get_DirectedMode(self): # Boolean
		return self.get_body_params().get('DirectedMode')

	def set_DirectedMode(self, DirectedMode):  # Boolean
		self.add_body_params('DirectedMode', DirectedMode)
	def get_Name(self): # String
		return self.get_body_params().get('Name')

	def set_Name(self, Name):  # String
		self.add_body_params('Name', Name)
	def get_NotifyTemplate(self): # String
		return self.get_body_params().get('NotifyTemplate')

	def set_NotifyTemplate(self, NotifyTemplate):  # String
		self.add_body_params('NotifyTemplate', NotifyTemplate)
