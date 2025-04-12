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

class CreateAgentlessScanTaskRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Sas', '2018-12-03', 'CreateAgentlessScanTask','sas')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_TargetType(self): # Integer
		return self.get_query_params().get('TargetType')

	def set_TargetType(self, TargetType):  # Integer
		self.add_query_param('TargetType', TargetType)
	def get_UuidLists(self): # RepeatList
		return self.get_query_params().get('UuidList')

	def set_UuidLists(self, UuidList):  # RepeatList
		for depth1 in range(len(UuidList)):
			self.add_query_param('UuidList.' + str(depth1 + 1), UuidList[depth1])
	def get_ScanDataDisk(self): # Boolean
		return self.get_query_params().get('ScanDataDisk')

	def set_ScanDataDisk(self, ScanDataDisk):  # Boolean
		self.add_query_param('ScanDataDisk', ScanDataDisk)
	def get_ReleaseAfterScan(self): # Boolean
		return self.get_query_params().get('ReleaseAfterScan')

	def set_ReleaseAfterScan(self, ReleaseAfterScan):  # Boolean
		self.add_query_param('ReleaseAfterScan', ReleaseAfterScan)
	def get_AutoDeleteDays(self): # Integer
		return self.get_query_params().get('AutoDeleteDays')

	def set_AutoDeleteDays(self, AutoDeleteDays):  # Integer
		self.add_query_param('AutoDeleteDays', AutoDeleteDays)
