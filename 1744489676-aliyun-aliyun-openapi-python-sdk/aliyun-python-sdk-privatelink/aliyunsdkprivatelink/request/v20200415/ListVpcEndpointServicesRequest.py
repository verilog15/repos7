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

class ListVpcEndpointServicesRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Privatelink', '2020-04-15', 'ListVpcEndpointServices','privatelink')
		self.set_protocol_type('https')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_ServiceBusinessStatus(self): # String
		return self.get_query_params().get('ServiceBusinessStatus')

	def set_ServiceBusinessStatus(self, ServiceBusinessStatus):  # String
		self.add_query_param('ServiceBusinessStatus', ServiceBusinessStatus)
	def get_AutoAcceptEnabled(self): # Boolean
		return self.get_query_params().get('AutoAcceptEnabled')

	def set_AutoAcceptEnabled(self, AutoAcceptEnabled):  # Boolean
		self.add_query_param('AutoAcceptEnabled', AutoAcceptEnabled)
	def get_ServiceStatus(self): # String
		return self.get_query_params().get('ServiceStatus')

	def set_ServiceStatus(self, ServiceStatus):  # String
		self.add_query_param('ServiceStatus', ServiceStatus)
	def get_ResourceGroupId(self): # String
		return self.get_query_params().get('ResourceGroupId')

	def set_ResourceGroupId(self, ResourceGroupId):  # String
		self.add_query_param('ResourceGroupId', ResourceGroupId)
	def get_NextToken(self): # String
		return self.get_query_params().get('NextToken')

	def set_NextToken(self, NextToken):  # String
		self.add_query_param('NextToken', NextToken)
	def get_ZoneAffinityEnabled(self): # Boolean
		return self.get_query_params().get('ZoneAffinityEnabled')

	def set_ZoneAffinityEnabled(self, ZoneAffinityEnabled):  # Boolean
		self.add_query_param('ZoneAffinityEnabled', ZoneAffinityEnabled)
	def get_ServiceName(self): # String
		return self.get_query_params().get('ServiceName')

	def set_ServiceName(self, ServiceName):  # String
		self.add_query_param('ServiceName', ServiceName)
	def get_Tag(self): # Array
		return self.get_query_params().get('Tag')

	def set_Tag(self, Tag):  # Array
		for index1, value1 in enumerate(Tag):
			if value1.get('Key') is not None:
				self.add_query_param('Tag.' + str(index1 + 1) + '.Key', value1.get('Key'))
			if value1.get('Value') is not None:
				self.add_query_param('Tag.' + str(index1 + 1) + '.Value', value1.get('Value'))
	def get_ResourceId(self): # String
		return self.get_query_params().get('ResourceId')

	def set_ResourceId(self, ResourceId):  # String
		self.add_query_param('ResourceId', ResourceId)
	def get_ServiceResourceType(self): # String
		return self.get_query_params().get('ServiceResourceType')

	def set_ServiceResourceType(self, ServiceResourceType):  # String
		self.add_query_param('ServiceResourceType', ServiceResourceType)
	def get_MaxResults(self): # Integer
		return self.get_query_params().get('MaxResults')

	def set_MaxResults(self, MaxResults):  # Integer
		self.add_query_param('MaxResults', MaxResults)
	def get_ServiceId(self): # String
		return self.get_query_params().get('ServiceId')

	def set_ServiceId(self, ServiceId):  # String
		self.add_query_param('ServiceId', ServiceId)
