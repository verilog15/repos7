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

class CreateOrUpdateSilencePolicyRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'ARMS', '2019-08-08', 'CreateOrUpdateSilencePolicy','arms')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_MatchingRules(self): # String
		return self.get_body_params().get('MatchingRules')

	def set_MatchingRules(self, MatchingRules):  # String
		self.add_body_params('MatchingRules', MatchingRules)
	def get_TimeSlots(self): # String
		return self.get_query_params().get('TimeSlots')

	def set_TimeSlots(self, TimeSlots):  # String
		self.add_query_param('TimeSlots', TimeSlots)
	def get_EffectiveTimeType(self): # String
		return self.get_query_params().get('EffectiveTimeType')

	def set_EffectiveTimeType(self, EffectiveTimeType):  # String
		self.add_query_param('EffectiveTimeType', EffectiveTimeType)
	def get_Name(self): # String
		return self.get_body_params().get('Name')

	def set_Name(self, Name):  # String
		self.add_body_params('Name', Name)
	def get_Id(self): # Long
		return self.get_body_params().get('Id')

	def set_Id(self, Id):  # Long
		self.add_body_params('Id', Id)
	def get_State(self): # String
		return self.get_body_params().get('State')

	def set_State(self, State):  # String
		self.add_body_params('State', State)
	def get_TimePeriod(self): # String
		return self.get_query_params().get('TimePeriod')

	def set_TimePeriod(self, TimePeriod):  # String
		self.add_query_param('TimePeriod', TimePeriod)
