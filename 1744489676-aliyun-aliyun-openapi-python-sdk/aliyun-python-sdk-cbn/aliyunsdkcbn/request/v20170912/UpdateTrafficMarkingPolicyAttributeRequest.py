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
from aliyunsdkcbn.endpoint import endpoint_data

class UpdateTrafficMarkingPolicyAttributeRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Cbn', '2017-09-12', 'UpdateTrafficMarkingPolicyAttribute','cbn')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_ResourceOwnerId(self): # Long
		return self.get_query_params().get('ResourceOwnerId')

	def set_ResourceOwnerId(self, ResourceOwnerId):  # Long
		self.add_query_param('ResourceOwnerId', ResourceOwnerId)
	def get_ClientToken(self): # String
		return self.get_query_params().get('ClientToken')

	def set_ClientToken(self, ClientToken):  # String
		self.add_query_param('ClientToken', ClientToken)
	def get_AddTrafficMatchRuless(self): # RepeatList
		return self.get_query_params().get('AddTrafficMatchRules')

	def set_AddTrafficMatchRuless(self, AddTrafficMatchRules):  # RepeatList
		for depth1 in range(len(AddTrafficMatchRules)):
			if AddTrafficMatchRules[depth1].get('DstPortRange') is not None:
				for depth2 in range(len(AddTrafficMatchRules[depth1].get('DstPortRange'))):
					self.add_query_param('AddTrafficMatchRules.' + str(depth1 + 1) + '.DstPortRange.' + str(depth2 + 1), AddTrafficMatchRules[depth1].get('DstPortRange')[depth2])
			if AddTrafficMatchRules[depth1].get('MatchDscp') is not None:
				self.add_query_param('AddTrafficMatchRules.' + str(depth1 + 1) + '.MatchDscp', AddTrafficMatchRules[depth1].get('MatchDscp'))
			if AddTrafficMatchRules[depth1].get('Protocol') is not None:
				self.add_query_param('AddTrafficMatchRules.' + str(depth1 + 1) + '.Protocol', AddTrafficMatchRules[depth1].get('Protocol'))
			if AddTrafficMatchRules[depth1].get('TrafficMatchRuleDescription') is not None:
				self.add_query_param('AddTrafficMatchRules.' + str(depth1 + 1) + '.TrafficMatchRuleDescription', AddTrafficMatchRules[depth1].get('TrafficMatchRuleDescription'))
			if AddTrafficMatchRules[depth1].get('SrcPortRange') is not None:
				for depth2 in range(len(AddTrafficMatchRules[depth1].get('SrcPortRange'))):
					self.add_query_param('AddTrafficMatchRules.' + str(depth1 + 1) + '.SrcPortRange.' + str(depth2 + 1), AddTrafficMatchRules[depth1].get('SrcPortRange')[depth2])
			if AddTrafficMatchRules[depth1].get('DstCidr') is not None:
				self.add_query_param('AddTrafficMatchRules.' + str(depth1 + 1) + '.DstCidr', AddTrafficMatchRules[depth1].get('DstCidr'))
			if AddTrafficMatchRules[depth1].get('TrafficMatchRuleName') is not None:
				self.add_query_param('AddTrafficMatchRules.' + str(depth1 + 1) + '.TrafficMatchRuleName', AddTrafficMatchRules[depth1].get('TrafficMatchRuleName'))
			if AddTrafficMatchRules[depth1].get('SrcCidr') is not None:
				self.add_query_param('AddTrafficMatchRules.' + str(depth1 + 1) + '.SrcCidr', AddTrafficMatchRules[depth1].get('SrcCidr'))
	def get_TrafficMarkingPolicyDescription(self): # String
		return self.get_query_params().get('TrafficMarkingPolicyDescription')

	def set_TrafficMarkingPolicyDescription(self, TrafficMarkingPolicyDescription):  # String
		self.add_query_param('TrafficMarkingPolicyDescription', TrafficMarkingPolicyDescription)
	def get_TrafficMarkingPolicyId(self): # String
		return self.get_query_params().get('TrafficMarkingPolicyId')

	def set_TrafficMarkingPolicyId(self, TrafficMarkingPolicyId):  # String
		self.add_query_param('TrafficMarkingPolicyId', TrafficMarkingPolicyId)
	def get_TrafficMarkingPolicyName(self): # String
		return self.get_query_params().get('TrafficMarkingPolicyName')

	def set_TrafficMarkingPolicyName(self, TrafficMarkingPolicyName):  # String
		self.add_query_param('TrafficMarkingPolicyName', TrafficMarkingPolicyName)
	def get_DryRun(self): # Boolean
		return self.get_query_params().get('DryRun')

	def set_DryRun(self, DryRun):  # Boolean
		self.add_query_param('DryRun', DryRun)
	def get_ResourceOwnerAccount(self): # String
		return self.get_query_params().get('ResourceOwnerAccount')

	def set_ResourceOwnerAccount(self, ResourceOwnerAccount):  # String
		self.add_query_param('ResourceOwnerAccount', ResourceOwnerAccount)
	def get_OwnerAccount(self): # String
		return self.get_query_params().get('OwnerAccount')

	def set_OwnerAccount(self, OwnerAccount):  # String
		self.add_query_param('OwnerAccount', OwnerAccount)
	def get_OwnerId(self): # Long
		return self.get_query_params().get('OwnerId')

	def set_OwnerId(self, OwnerId):  # Long
		self.add_query_param('OwnerId', OwnerId)
	def get_DeleteTrafficMatchRuless(self): # RepeatList
		return self.get_query_params().get('DeleteTrafficMatchRules')

	def set_DeleteTrafficMatchRuless(self, DeleteTrafficMatchRules):  # RepeatList
		for depth1 in range(len(DeleteTrafficMatchRules)):
			if DeleteTrafficMatchRules[depth1].get('DstPortRange') is not None:
				for depth2 in range(len(DeleteTrafficMatchRules[depth1].get('DstPortRange'))):
					self.add_query_param('DeleteTrafficMatchRules.' + str(depth1 + 1) + '.DstPortRange.' + str(depth2 + 1), DeleteTrafficMatchRules[depth1].get('DstPortRange')[depth2])
			if DeleteTrafficMatchRules[depth1].get('MatchDscp') is not None:
				self.add_query_param('DeleteTrafficMatchRules.' + str(depth1 + 1) + '.MatchDscp', DeleteTrafficMatchRules[depth1].get('MatchDscp'))
			if DeleteTrafficMatchRules[depth1].get('Protocol') is not None:
				self.add_query_param('DeleteTrafficMatchRules.' + str(depth1 + 1) + '.Protocol', DeleteTrafficMatchRules[depth1].get('Protocol'))
			if DeleteTrafficMatchRules[depth1].get('TrafficMatchRuleDescription') is not None:
				self.add_query_param('DeleteTrafficMatchRules.' + str(depth1 + 1) + '.TrafficMatchRuleDescription', DeleteTrafficMatchRules[depth1].get('TrafficMatchRuleDescription'))
			if DeleteTrafficMatchRules[depth1].get('SrcPortRange') is not None:
				for depth2 in range(len(DeleteTrafficMatchRules[depth1].get('SrcPortRange'))):
					self.add_query_param('DeleteTrafficMatchRules.' + str(depth1 + 1) + '.SrcPortRange.' + str(depth2 + 1), DeleteTrafficMatchRules[depth1].get('SrcPortRange')[depth2])
			if DeleteTrafficMatchRules[depth1].get('DstCidr') is not None:
				self.add_query_param('DeleteTrafficMatchRules.' + str(depth1 + 1) + '.DstCidr', DeleteTrafficMatchRules[depth1].get('DstCidr'))
			if DeleteTrafficMatchRules[depth1].get('TrafficMatchRuleName') is not None:
				self.add_query_param('DeleteTrafficMatchRules.' + str(depth1 + 1) + '.TrafficMatchRuleName', DeleteTrafficMatchRules[depth1].get('TrafficMatchRuleName'))
			if DeleteTrafficMatchRules[depth1].get('SrcCidr') is not None:
				self.add_query_param('DeleteTrafficMatchRules.' + str(depth1 + 1) + '.SrcCidr', DeleteTrafficMatchRules[depth1].get('SrcCidr'))
