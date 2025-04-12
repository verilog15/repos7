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
from aliyunsdkalb.endpoint import endpoint_data

class UpdateLoadBalancerAddressTypeConfigRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Alb', '2020-06-16', 'UpdateLoadBalancerAddressTypeConfig','alb')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_ClientToken(self): # String
		return self.get_query_params().get('ClientToken')

	def set_ClientToken(self, ClientToken):  # String
		self.add_query_param('ClientToken', ClientToken)
	def get_AddressType(self): # String
		return self.get_query_params().get('AddressType')

	def set_AddressType(self, AddressType):  # String
		self.add_query_param('AddressType', AddressType)
	def get_DryRun(self): # String
		return self.get_query_params().get('DryRun')

	def set_DryRun(self, DryRun):  # String
		self.add_query_param('DryRun', DryRun)
	def get_ZoneMappings(self): # Array
		return self.get_query_params().get('ZoneMappings')

	def set_ZoneMappings(self, ZoneMappings):  # Array
		for index1, value1 in enumerate(ZoneMappings):
			if value1.get('VSwitchId') is not None:
				self.add_query_param('ZoneMappings.' + str(index1 + 1) + '.VSwitchId', value1.get('VSwitchId'))
			if value1.get('EipType') is not None:
				self.add_query_param('ZoneMappings.' + str(index1 + 1) + '.EipType', value1.get('EipType'))
			if value1.get('ZoneId') is not None:
				self.add_query_param('ZoneMappings.' + str(index1 + 1) + '.ZoneId', value1.get('ZoneId'))
			if value1.get('AllocationId') is not None:
				self.add_query_param('ZoneMappings.' + str(index1 + 1) + '.AllocationId', value1.get('AllocationId'))
	def get_LoadBalancerId(self): # String
		return self.get_query_params().get('LoadBalancerId')

	def set_LoadBalancerId(self, LoadBalancerId):  # String
		self.add_query_param('LoadBalancerId', LoadBalancerId)
