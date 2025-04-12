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

class ModifyWebLockUpdateConfigRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Sas', '2018-12-03', 'ModifyWebLockUpdateConfig','sas')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_LocalBackupDir(self): # String
		return self.get_query_params().get('LocalBackupDir')

	def set_LocalBackupDir(self, LocalBackupDir):  # String
		self.add_query_param('LocalBackupDir', LocalBackupDir)
	def get_ExclusiveFile(self): # String
		return self.get_query_params().get('ExclusiveFile')

	def set_ExclusiveFile(self, ExclusiveFile):  # String
		self.add_query_param('ExclusiveFile', ExclusiveFile)
	def get_ExclusiveFileType(self): # String
		return self.get_query_params().get('ExclusiveFileType')

	def set_ExclusiveFileType(self, ExclusiveFileType):  # String
		self.add_query_param('ExclusiveFileType', ExclusiveFileType)
	def get_Dir(self): # String
		return self.get_query_params().get('Dir')

	def set_Dir(self, Dir):  # String
		self.add_query_param('Dir', Dir)
	def get_Uuid(self): # String
		return self.get_query_params().get('Uuid')

	def set_Uuid(self, Uuid):  # String
		self.add_query_param('Uuid', Uuid)
	def get_Mode(self): # String
		return self.get_query_params().get('Mode')

	def set_Mode(self, Mode):  # String
		self.add_query_param('Mode', Mode)
	def get_SourceIp(self): # String
		return self.get_query_params().get('SourceIp')

	def set_SourceIp(self, SourceIp):  # String
		self.add_query_param('SourceIp', SourceIp)
	def get_Id(self): # Integer
		return self.get_query_params().get('Id')

	def set_Id(self, Id):  # Integer
		self.add_query_param('Id', Id)
	def get_Lang(self): # String
		return self.get_query_params().get('Lang')

	def set_Lang(self, Lang):  # String
		self.add_query_param('Lang', Lang)
	def get_InclusiveFile(self): # String
		return self.get_query_params().get('InclusiveFile')

	def set_InclusiveFile(self, InclusiveFile):  # String
		self.add_query_param('InclusiveFile', InclusiveFile)
	def get_ExclusiveDir(self): # String
		return self.get_query_params().get('ExclusiveDir')

	def set_ExclusiveDir(self, ExclusiveDir):  # String
		self.add_query_param('ExclusiveDir', ExclusiveDir)
	def get_InclusiveFileType(self): # String
		return self.get_query_params().get('InclusiveFileType')

	def set_InclusiveFileType(self, InclusiveFileType):  # String
		self.add_query_param('InclusiveFileType', InclusiveFileType)
	def get_DefenceMode(self): # String
		return self.get_query_params().get('DefenceMode')

	def set_DefenceMode(self, DefenceMode):  # String
		self.add_query_param('DefenceMode', DefenceMode)
