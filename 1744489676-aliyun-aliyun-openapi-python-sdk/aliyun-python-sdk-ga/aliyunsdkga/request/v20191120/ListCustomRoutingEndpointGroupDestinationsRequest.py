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
from aliyunsdkga.endpoint import endpoint_data

class ListCustomRoutingEndpointGroupDestinationsRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Ga', '2019-11-20', 'ListCustomRoutingEndpointGroupDestinations','gaplus')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_PageNumber(self): # Integer
		return self.get_query_params().get('PageNumber')

	def set_PageNumber(self, PageNumber):  # Integer
		self.add_query_param('PageNumber', PageNumber)
	def get_ListenerId(self): # String
		return self.get_query_params().get('ListenerId')

	def set_ListenerId(self, ListenerId):  # String
		self.add_query_param('ListenerId', ListenerId)
	def get_FromPort(self): # Integer
		return self.get_query_params().get('FromPort')

	def set_FromPort(self, FromPort):  # Integer
		self.add_query_param('FromPort', FromPort)
	def get_PageSize(self): # Integer
		return self.get_query_params().get('PageSize')

	def set_PageSize(self, PageSize):  # Integer
		self.add_query_param('PageSize', PageSize)
	def get_AcceleratorId(self): # String
		return self.get_query_params().get('AcceleratorId')

	def set_AcceleratorId(self, AcceleratorId):  # String
		self.add_query_param('AcceleratorId', AcceleratorId)
	def get_Protocolss(self): # RepeatList
		return self.get_query_params().get('Protocols')

	def set_Protocolss(self, Protocols):  # RepeatList
		for depth1 in range(len(Protocols)):
			self.add_query_param('Protocols.' + str(depth1 + 1), Protocols[depth1])
	def get_ToPort(self): # Integer
		return self.get_query_params().get('ToPort')

	def set_ToPort(self, ToPort):  # Integer
		self.add_query_param('ToPort', ToPort)
	def get_EndpointGroupId(self): # String
		return self.get_query_params().get('EndpointGroupId')

	def set_EndpointGroupId(self, EndpointGroupId):  # String
		self.add_query_param('EndpointGroupId', EndpointGroupId)
