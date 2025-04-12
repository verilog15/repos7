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
from aliyunsdkimm.endpoint import endpoint_data
import json

class CreateFileCompressionTaskRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'imm', '2020-09-30', 'CreateFileCompressionTask','imm')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_Sources(self): # Array
		return self.get_query_params().get('Sources')

	def set_Sources(self, Sources):  # Array
		self.add_query_param("Sources", json.dumps(Sources))
	def get_SourceManifestURI(self): # String
		return self.get_query_params().get('SourceManifestURI')

	def set_SourceManifestURI(self, SourceManifestURI):  # String
		self.add_query_param('SourceManifestURI', SourceManifestURI)
	def get_UserData(self): # String
		return self.get_query_params().get('UserData')

	def set_UserData(self, UserData):  # String
		self.add_query_param('UserData', UserData)
	def get_Notification(self): # Struct
		return self.get_query_params().get('Notification')

	def set_Notification(self, Notification):  # Struct
		self.add_query_param("Notification", json.dumps(Notification))
	def get_TargetURI(self): # String
		return self.get_query_params().get('TargetURI')

	def set_TargetURI(self, TargetURI):  # String
		self.add_query_param('TargetURI', TargetURI)
	def get_ProjectName(self): # String
		return self.get_query_params().get('ProjectName')

	def set_ProjectName(self, ProjectName):  # String
		self.add_query_param('ProjectName', ProjectName)
	def get_CredentialConfig(self): # Struct
		return self.get_query_params().get('CredentialConfig')

	def set_CredentialConfig(self, CredentialConfig):  # Struct
		self.add_query_param("CredentialConfig", json.dumps(CredentialConfig))
	def get_CompressedFormat(self): # String
		return self.get_query_params().get('CompressedFormat')

	def set_CompressedFormat(self, CompressedFormat):  # String
		self.add_query_param('CompressedFormat', CompressedFormat)
