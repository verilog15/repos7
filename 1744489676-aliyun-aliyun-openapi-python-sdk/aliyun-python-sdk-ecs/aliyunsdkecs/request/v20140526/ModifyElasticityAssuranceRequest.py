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
from aliyunsdkecs.endpoint import endpoint_data

class ModifyElasticityAssuranceRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Ecs', '2014-05-26', 'ModifyElasticityAssurance','ecs')
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
	def get_Description(self): # String
		return self.get_query_params().get('Description')

	def set_Description(self, Description):  # String
		self.add_query_param('Description', Description)
	def get_PrivatePoolOptionsId(self): # String
		return self.get_query_params().get('PrivatePoolOptions.Id')

	def set_PrivatePoolOptionsId(self, PrivatePoolOptionsId):  # String
		self.add_query_param('PrivatePoolOptions.Id', PrivatePoolOptionsId)
	def get_ResourceOwnerAccount(self): # String
		return self.get_query_params().get('ResourceOwnerAccount')

	def set_ResourceOwnerAccount(self, ResourceOwnerAccount):  # String
		self.add_query_param('ResourceOwnerAccount', ResourceOwnerAccount)
	def get_PrivatePoolOptionsName(self): # String
		return self.get_query_params().get('PrivatePoolOptions.Name')

	def set_PrivatePoolOptionsName(self, PrivatePoolOptionsName):  # String
		self.add_query_param('PrivatePoolOptions.Name', PrivatePoolOptionsName)
	def get_OwnerAccount(self): # String
		return self.get_query_params().get('OwnerAccount')

	def set_OwnerAccount(self, OwnerAccount):  # String
		self.add_query_param('OwnerAccount', OwnerAccount)
	def get_OwnerId(self): # Long
		return self.get_query_params().get('OwnerId')

	def set_OwnerId(self, OwnerId):  # Long
		self.add_query_param('OwnerId', OwnerId)
	def get_RecurrenceRuless(self): # RepeatList
		return self.get_query_params().get('RecurrenceRules')

	def set_RecurrenceRuless(self, RecurrenceRules):  # RepeatList
		for depth1 in range(len(RecurrenceRules)):
			if RecurrenceRules[depth1].get('RecurrenceType') is not None:
				self.add_query_param('RecurrenceRules.' + str(depth1 + 1) + '.RecurrenceType', RecurrenceRules[depth1].get('RecurrenceType'))
			if RecurrenceRules[depth1].get('RecurrenceValue') is not None:
				self.add_query_param('RecurrenceRules.' + str(depth1 + 1) + '.RecurrenceValue', RecurrenceRules[depth1].get('RecurrenceValue'))
			if RecurrenceRules[depth1].get('StartHour') is not None:
				self.add_query_param('RecurrenceRules.' + str(depth1 + 1) + '.StartHour', RecurrenceRules[depth1].get('StartHour'))
			if RecurrenceRules[depth1].get('EndHour') is not None:
				self.add_query_param('RecurrenceRules.' + str(depth1 + 1) + '.EndHour', RecurrenceRules[depth1].get('EndHour'))
	def get_InstanceAmount(self): # Integer
		return self.get_query_params().get('InstanceAmount')

	def set_InstanceAmount(self, InstanceAmount):  # Integer
		self.add_query_param('InstanceAmount', InstanceAmount)
