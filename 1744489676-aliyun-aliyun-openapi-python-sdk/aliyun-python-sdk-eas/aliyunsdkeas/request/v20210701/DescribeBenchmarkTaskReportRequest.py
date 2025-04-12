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

from aliyunsdkcore.request import RoaRequest
from aliyunsdkeas.endpoint import endpoint_data

class DescribeBenchmarkTaskReportRequest(RoaRequest):

	def __init__(self):
		RoaRequest.__init__(self, 'eas', '2021-07-01', 'DescribeBenchmarkTaskReport','eas')
		self.set_uri_pattern('/api/v2/benchmark-tasks/[ClusterId]/[TaskName]/report')
		self.set_method('GET')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_ReportType(self): # String
		return self.get_query_params().get('ReportType')

	def set_ReportType(self, ReportType):  # String
		self.add_query_param('ReportType', ReportType)
	def get_TaskName(self): # String
		return self.get_path_params().get('TaskName')

	def set_TaskName(self, TaskName):  # String
		self.add_path_param('TaskName', TaskName)
	def get_ClusterId(self): # String
		return self.get_path_params().get('ClusterId')

	def set_ClusterId(self, ClusterId):  # String
		self.add_path_param('ClusterId', ClusterId)
