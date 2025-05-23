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
from aliyunsdknas.endpoint import endpoint_data

class SetFilesetQuotaRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'NAS', '2017-06-26', 'SetFilesetQuota','nas')
		self.set_protocol_type('https')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_FsetId(self): # String
		return self.get_query_params().get('FsetId')

	def set_FsetId(self, FsetId):  # String
		self.add_query_param('FsetId', FsetId)
	def get_ClientToken(self): # String
		return self.get_query_params().get('ClientToken')

	def set_ClientToken(self, ClientToken):  # String
		self.add_query_param('ClientToken', ClientToken)
	def get_FileCountLimit(self): # Long
		return self.get_query_params().get('FileCountLimit')

	def set_FileCountLimit(self, FileCountLimit):  # Long
		self.add_query_param('FileCountLimit', FileCountLimit)
	def get_SizeLimit(self): # Long
		return self.get_query_params().get('SizeLimit')

	def set_SizeLimit(self, SizeLimit):  # Long
		self.add_query_param('SizeLimit', SizeLimit)
	def get_FileSystemId(self): # String
		return self.get_query_params().get('FileSystemId')

	def set_FileSystemId(self, FileSystemId):  # String
		self.add_query_param('FileSystemId', FileSystemId)
	def get_DryRun(self): # Boolean
		return self.get_query_params().get('DryRun')

	def set_DryRun(self, DryRun):  # Boolean
		self.add_query_param('DryRun', DryRun)
