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
from aliyunsdkehpc.endpoint import endpoint_data

class GetAccountingReportRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'EHPC', '2018-04-12', 'GetAccountingReport','ehs')
		self.set_method('GET')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_ReportType(self): # String
		return self.get_query_params().get('ReportType')

	def set_ReportType(self, ReportType):  # String
		self.add_query_param('ReportType', ReportType)
	def get_EndTime(self): # Integer
		return self.get_query_params().get('EndTime')

	def set_EndTime(self, EndTime):  # Integer
		self.add_query_param('EndTime', EndTime)
	def get_FilterValue(self): # String
		return self.get_query_params().get('FilterValue')

	def set_FilterValue(self, FilterValue):  # String
		self.add_query_param('FilterValue', FilterValue)
	def get_Dim(self): # String
		return self.get_query_params().get('Dim')

	def set_Dim(self, Dim):  # String
		self.add_query_param('Dim', Dim)
	def get_ClusterId(self): # String
		return self.get_query_params().get('ClusterId')

	def set_ClusterId(self, ClusterId):  # String
		self.add_query_param('ClusterId', ClusterId)
	def get_StartTime(self): # Integer
		return self.get_query_params().get('StartTime')

	def set_StartTime(self, StartTime):  # Integer
		self.add_query_param('StartTime', StartTime)
	def get_PageNumber(self): # Integer
		return self.get_query_params().get('PageNumber')

	def set_PageNumber(self, PageNumber):  # Integer
		self.add_query_param('PageNumber', PageNumber)
	def get_JobId(self): # String
		return self.get_query_params().get('JobId')

	def set_JobId(self, JobId):  # String
		self.add_query_param('JobId', JobId)
	def get_PageSize(self): # Integer
		return self.get_query_params().get('PageSize')

	def set_PageSize(self, PageSize):  # Integer
		self.add_query_param('PageSize', PageSize)
