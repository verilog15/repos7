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

class GetCodeCompletionRequest(RoaRequest):

	def __init__(self):
		RoaRequest.__init__(self, 'codeup', '2020-04-14', 'GetCodeCompletion')
		self.set_uri_pattern('/api/v2/service/invoke/[ServiceName]')
		self.set_method('POST')

	def get_IsEncrypted(self):
		return self.get_query_params().get('IsEncrypted')

	def set_IsEncrypted(self,IsEncrypted):
		self.add_query_param('IsEncrypted',IsEncrypted)

	def get_FetchKeys(self):
		return self.get_query_params().get('FetchKeys')

	def set_FetchKeys(self,FetchKeys):
		self.add_query_param('FetchKeys',FetchKeys)

	def get_ServiceName(self):
		return self.get_path_params().get('ServiceName')

	def set_ServiceName(self,ServiceName):
		self.add_path_param('ServiceName',ServiceName)