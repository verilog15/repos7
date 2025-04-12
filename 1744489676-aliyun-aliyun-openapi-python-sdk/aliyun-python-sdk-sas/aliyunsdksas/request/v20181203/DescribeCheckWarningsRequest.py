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

class DescribeCheckWarningsRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Sas', '2018-12-03', 'DescribeCheckWarnings','sas')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_ContainerName(self): # String
		return self.get_query_params().get('ContainerName')

	def set_ContainerName(self, ContainerName):  # String
		self.add_query_param('ContainerName', ContainerName)
	def get_Uuid(self): # String
		return self.get_query_params().get('Uuid')

	def set_Uuid(self, Uuid):  # String
		self.add_query_param('Uuid', Uuid)
	def get_CheckType(self): # String
		return self.get_query_params().get('CheckType')

	def set_CheckType(self, CheckType):  # String
		self.add_query_param('CheckType', CheckType)
	def get_SourceIp(self): # String
		return self.get_query_params().get('SourceIp')

	def set_SourceIp(self, SourceIp):  # String
		self.add_query_param('SourceIp', SourceIp)
	def get_PageSize(self): # Integer
		return self.get_query_params().get('PageSize')

	def set_PageSize(self, PageSize):  # Integer
		self.add_query_param('PageSize', PageSize)
	def get_Lang(self): # String
		return self.get_query_params().get('Lang')

	def set_Lang(self, Lang):  # String
		self.add_query_param('Lang', Lang)
	def get_CheckId(self): # Long
		return self.get_query_params().get('CheckId')

	def set_CheckId(self, CheckId):  # Long
		self.add_query_param('CheckId', CheckId)
	def get_CurrentPage(self): # Integer
		return self.get_query_params().get('CurrentPage')

	def set_CurrentPage(self, CurrentPage):  # Integer
		self.add_query_param('CurrentPage', CurrentPage)
	def get_RiskId(self): # Long
		return self.get_query_params().get('RiskId')

	def set_RiskId(self, RiskId):  # Long
		self.add_query_param('RiskId', RiskId)
	def get_RiskStatus(self): # Integer
		return self.get_query_params().get('RiskStatus')

	def set_RiskStatus(self, RiskStatus):  # Integer
		self.add_query_param('RiskStatus', RiskStatus)
