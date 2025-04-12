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
from aliyunsdkcomputenestsupplier.endpoint import endpoint_data

class GetServiceRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'ComputeNestSupplier', '2021-05-21', 'GetService')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_ShowDetails(self): # RepeatList
		return self.get_query_params().get('ShowDetail')

	def set_ShowDetails(self, ShowDetail):  # RepeatList
		for depth1 in range(len(ShowDetail)):
			self.add_query_param('ShowDetail.' + str(depth1 + 1), ShowDetail[depth1])
	def get_SharedAccountType(self): # String
		return self.get_query_params().get('SharedAccountType')

	def set_SharedAccountType(self, SharedAccountType):  # String
		self.add_query_param('SharedAccountType', SharedAccountType)
	def get_FilterAliUid(self): # Boolean
		return self.get_query_params().get('FilterAliUid')

	def set_FilterAliUid(self, FilterAliUid):  # Boolean
		self.add_query_param('FilterAliUid', FilterAliUid)
	def get_ServiceVersion(self): # String
		return self.get_query_params().get('ServiceVersion')

	def set_ServiceVersion(self, ServiceVersion):  # String
		self.add_query_param('ServiceVersion', ServiceVersion)
	def get_ServiceId(self): # String
		return self.get_query_params().get('ServiceId')

	def set_ServiceId(self, ServiceId):  # String
		self.add_query_param('ServiceId', ServiceId)
