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
from aliyunsdkprivatelink.endpoint import endpoint_data

class ListVpcEndpointConnectionsRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Privatelink', '2020-04-15', 'ListVpcEndpointConnections','privatelink')
		self.set_protocol_type('https')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_EndpointId(self): # String
		return self.get_query_params().get('EndpointId')

	def set_EndpointId(self, EndpointId):  # String
		self.add_query_param('EndpointId', EndpointId)
	def get_EndpointOwnerId(self): # Long
		return self.get_query_params().get('EndpointOwnerId')

	def set_EndpointOwnerId(self, EndpointOwnerId):  # Long
		self.add_query_param('EndpointOwnerId', EndpointOwnerId)
	def get_ReplacedResourceId(self): # String
		return self.get_query_params().get('ReplacedResourceId')

	def set_ReplacedResourceId(self, ReplacedResourceId):  # String
		self.add_query_param('ReplacedResourceId', ReplacedResourceId)
	def get_ResourceGroupId(self): # String
		return self.get_query_params().get('ResourceGroupId')

	def set_ResourceGroupId(self, ResourceGroupId):  # String
		self.add_query_param('ResourceGroupId', ResourceGroupId)
	def get_NextToken(self): # String
		return self.get_query_params().get('NextToken')

	def set_NextToken(self, NextToken):  # String
		self.add_query_param('NextToken', NextToken)
	def get_ConnectionId(self): # Long
		return self.get_query_params().get('ConnectionId')

	def set_ConnectionId(self, ConnectionId):  # Long
		self.add_query_param('ConnectionId', ConnectionId)
	def get_ResourceId(self): # String
		return self.get_query_params().get('ResourceId')

	def set_ResourceId(self, ResourceId):  # String
		self.add_query_param('ResourceId', ResourceId)
	def get_ConnectionStatus(self): # String
		return self.get_query_params().get('ConnectionStatus')

	def set_ConnectionStatus(self, ConnectionStatus):  # String
		self.add_query_param('ConnectionStatus', ConnectionStatus)
	def get_MaxResults(self): # Integer
		return self.get_query_params().get('MaxResults')

	def set_MaxResults(self, MaxResults):  # Integer
		self.add_query_param('MaxResults', MaxResults)
	def get_EniId(self): # String
		return self.get_query_params().get('EniId')

	def set_EniId(self, EniId):  # String
		self.add_query_param('EniId', EniId)
	def get_ServiceId(self): # String
		return self.get_query_params().get('ServiceId')

	def set_ServiceId(self, ServiceId):  # String
		self.add_query_param('ServiceId', ServiceId)
