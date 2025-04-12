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
from aliyunsdkhbr.endpoint import endpoint_data

class DescribeHanaBackupsAsyncRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'hbr', '2017-09-08', 'DescribeHanaBackupsAsync','hbr')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_RecoveryPointInTime(self): # Long
		return self.get_query_params().get('RecoveryPointInTime')

	def set_RecoveryPointInTime(self, RecoveryPointInTime):  # Long
		self.add_query_param('RecoveryPointInTime', RecoveryPointInTime)
	def get_LogPosition(self): # Long
		return self.get_query_params().get('LogPosition')

	def set_LogPosition(self, LogPosition):  # Long
		self.add_query_param('LogPosition', LogPosition)
	def get_VaultId(self): # String
		return self.get_query_params().get('VaultId')

	def set_VaultId(self, VaultId):  # String
		self.add_query_param('VaultId', VaultId)
	def get_IncludeLog(self): # Boolean
		return self.get_query_params().get('IncludeLog')

	def set_IncludeLog(self, IncludeLog):  # Boolean
		self.add_query_param('IncludeLog', IncludeLog)
	def get_Source(self): # String
		return self.get_query_params().get('Source')

	def set_Source(self, Source):  # String
		self.add_query_param('Source', Source)
	def get_PageNumber(self): # Integer
		return self.get_query_params().get('PageNumber')

	def set_PageNumber(self, PageNumber):  # Integer
		self.add_query_param('PageNumber', PageNumber)
	def get_Mode(self): # String
		return self.get_query_params().get('Mode')

	def set_Mode(self, Mode):  # String
		self.add_query_param('Mode', Mode)
	def get_ResourceGroupId(self): # String
		return self.get_query_params().get('ResourceGroupId')

	def set_ResourceGroupId(self, ResourceGroupId):  # String
		self.add_query_param('ResourceGroupId', ResourceGroupId)
	def get_IncludeIncremental(self): # Boolean
		return self.get_query_params().get('IncludeIncremental')

	def set_IncludeIncremental(self, IncludeIncremental):  # Boolean
		self.add_query_param('IncludeIncremental', IncludeIncremental)
	def get_PageSize(self): # Integer
		return self.get_query_params().get('PageSize')

	def set_PageSize(self, PageSize):  # Integer
		self.add_query_param('PageSize', PageSize)
	def get_ClusterId(self): # String
		return self.get_query_params().get('ClusterId')

	def set_ClusterId(self, ClusterId):  # String
		self.add_query_param('ClusterId', ClusterId)
	def get_UseBackint(self): # Boolean
		return self.get_query_params().get('UseBackint')

	def set_UseBackint(self, UseBackint):  # Boolean
		self.add_query_param('UseBackint', UseBackint)
	def get_DatabaseName(self): # String
		return self.get_query_params().get('DatabaseName')

	def set_DatabaseName(self, DatabaseName):  # String
		self.add_query_param('DatabaseName', DatabaseName)
	def get_VolumeId(self): # Integer
		return self.get_query_params().get('VolumeId')

	def set_VolumeId(self, VolumeId):  # Integer
		self.add_query_param('VolumeId', VolumeId)
	def get_SourceClusterId(self): # String
		return self.get_query_params().get('SourceClusterId')

	def set_SourceClusterId(self, SourceClusterId):  # String
		self.add_query_param('SourceClusterId', SourceClusterId)
	def get_IncludeDifferential(self): # Boolean
		return self.get_query_params().get('IncludeDifferential')

	def set_IncludeDifferential(self, IncludeDifferential):  # Boolean
		self.add_query_param('IncludeDifferential', IncludeDifferential)
	def get_SystemCopy(self): # Boolean
		return self.get_query_params().get('SystemCopy')

	def set_SystemCopy(self, SystemCopy):  # Boolean
		self.add_query_param('SystemCopy', SystemCopy)
