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
from aliyunsdksas.endpoint import endpoint_data

class DescribeWarningMachinesRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Sas', '2018-12-03', 'DescribeWarningMachines','sas')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_TargetType(self): # String
		return self.get_query_params().get('TargetType')

	def set_TargetType(self, TargetType):  # String
		self.add_query_param('TargetType', TargetType)
	def get_ContainerFieldName(self): # String
		return self.get_query_params().get('ContainerFieldName')

	def set_ContainerFieldName(self, ContainerFieldName):  # String
		self.add_query_param('ContainerFieldName', ContainerFieldName)
	def get_SourceIp(self): # String
		return self.get_query_params().get('SourceIp')

	def set_SourceIp(self, SourceIp):  # String
		self.add_query_param('SourceIp', SourceIp)
	def get_ContainerFieldValue(self): # String
		return self.get_query_params().get('ContainerFieldValue')

	def set_ContainerFieldValue(self, ContainerFieldValue):  # String
		self.add_query_param('ContainerFieldValue', ContainerFieldValue)
	def get_PageSize(self): # Integer
		return self.get_query_params().get('PageSize')

	def set_PageSize(self, PageSize):  # Integer
		self.add_query_param('PageSize', PageSize)
	def get_MachineName(self): # String
		return self.get_query_params().get('MachineName')

	def set_MachineName(self, MachineName):  # String
		self.add_query_param('MachineName', MachineName)
	def get_Lang(self): # String
		return self.get_query_params().get('Lang')

	def set_Lang(self, Lang):  # String
		self.add_query_param('Lang', Lang)
	def get_HaveRisk(self): # Integer
		return self.get_query_params().get('HaveRisk')

	def set_HaveRisk(self, HaveRisk):  # Integer
		self.add_query_param('HaveRisk', HaveRisk)
	def get_GroupId(self): # Long
		return self.get_query_params().get('GroupId')

	def set_GroupId(self, GroupId):  # Long
		self.add_query_param('GroupId', GroupId)
	def get_CurrentPage(self): # Integer
		return self.get_query_params().get('CurrentPage')

	def set_CurrentPage(self, CurrentPage):  # Integer
		self.add_query_param('CurrentPage', CurrentPage)
	def get_ClusterId(self): # String
		return self.get_query_params().get('ClusterId')

	def set_ClusterId(self, ClusterId):  # String
		self.add_query_param('ClusterId', ClusterId)
	def get_RiskId(self): # Long
		return self.get_query_params().get('RiskId')

	def set_RiskId(self, RiskId):  # Long
		self.add_query_param('RiskId', RiskId)
	def get_StrategyId(self): # Long
		return self.get_query_params().get('StrategyId')

	def set_StrategyId(self, StrategyId):  # Long
		self.add_query_param('StrategyId', StrategyId)
	def get_Uuids(self): # String
		return self.get_query_params().get('Uuids')

	def set_Uuids(self, Uuids):  # String
		self.add_query_param('Uuids', Uuids)
