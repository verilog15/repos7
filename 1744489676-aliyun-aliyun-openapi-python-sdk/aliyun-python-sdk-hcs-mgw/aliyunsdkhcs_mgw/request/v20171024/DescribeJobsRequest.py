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

class DescribeJobsRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'hcs-mgw', '2017-10-24', 'DescribeJobs')
		self.set_method('POST')

	def get_JobType(self):
		return self.get_query_params().get('JobType')

	def set_JobType(self,JobType):
		self.add_query_param('JobType',JobType)

	def get_PageNumber(self):
		return self.get_query_params().get('PageNumber')

	def set_PageNumber(self,PageNumber):
		self.add_query_param('PageNumber',PageNumber)

	def get_PageSize(self):
		return self.get_query_params().get('PageSize')

	def set_PageSize(self,PageSize):
		self.add_query_param('PageSize',PageSize)

	def get_MgwRegionId(self):
		return self.get_query_params().get('MgwRegionId')

	def set_MgwRegionId(self,MgwRegionId):
		self.add_query_param('MgwRegionId',MgwRegionId)

	def get_JobName(self):
		return self.get_query_params().get('JobName')

	def set_JobName(self,JobName):
		self.add_query_param('JobName',JobName)