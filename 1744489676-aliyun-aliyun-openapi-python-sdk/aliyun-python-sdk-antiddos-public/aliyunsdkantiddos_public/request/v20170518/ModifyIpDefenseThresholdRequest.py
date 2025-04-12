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
from aliyunsdkantiddos_public.endpoint import endpoint_data

class ModifyIpDefenseThresholdRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'antiddos-public', '2017-05-18', 'ModifyIpDefenseThreshold','ddosbasic')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_InternetIp(self): # String
		return self.get_query_params().get('InternetIp')

	def set_InternetIp(self, InternetIp):  # String
		self.add_query_param('InternetIp', InternetIp)
	def get_DdosRegionId(self): # String
		return self.get_query_params().get('DdosRegionId')

	def set_DdosRegionId(self, DdosRegionId):  # String
		self.add_query_param('DdosRegionId', DdosRegionId)
	def get_InstanceType(self): # String
		return self.get_query_params().get('InstanceType')

	def set_InstanceType(self, InstanceType):  # String
		self.add_query_param('InstanceType', InstanceType)
	def get_Bps(self): # Integer
		return self.get_query_params().get('Bps')

	def set_Bps(self, Bps):  # Integer
		self.add_query_param('Bps', Bps)
	def get_Pps(self): # Integer
		return self.get_query_params().get('Pps')

	def set_Pps(self, Pps):  # Integer
		self.add_query_param('Pps', Pps)
	def get_InstanceId(self): # String
		return self.get_query_params().get('InstanceId')

	def set_InstanceId(self, InstanceId):  # String
		self.add_query_param('InstanceId', InstanceId)
	def get_IsAuto(self): # Boolean
		return self.get_query_params().get('IsAuto')

	def set_IsAuto(self, IsAuto):  # Boolean
		self.add_query_param('IsAuto', IsAuto)
