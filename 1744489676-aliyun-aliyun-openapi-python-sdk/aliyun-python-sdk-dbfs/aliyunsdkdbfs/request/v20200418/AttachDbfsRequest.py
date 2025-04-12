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
from aliyunsdkdbfs.endpoint import endpoint_data

class AttachDbfsRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'DBFS', '2020-04-18', 'AttachDbfs','dbfs')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_ECSInstanceId(self): # String
		return self.get_query_params().get('ECSInstanceId')

	def set_ECSInstanceId(self, ECSInstanceId):  # String
		self.add_query_param('ECSInstanceId', ECSInstanceId)
	def get_AttachPoint(self): # String
		return self.get_query_params().get('AttachPoint')

	def set_AttachPoint(self, AttachPoint):  # String
		self.add_query_param('AttachPoint', AttachPoint)
	def get_ServerUrl(self): # String
		return self.get_query_params().get('ServerUrl')

	def set_ServerUrl(self, ServerUrl):  # String
		self.add_query_param('ServerUrl', ServerUrl)
	def get_FsId(self): # String
		return self.get_query_params().get('FsId')

	def set_FsId(self, FsId):  # String
		self.add_query_param('FsId', FsId)
	def get_AttachMode(self): # String
		return self.get_query_params().get('AttachMode')

	def set_AttachMode(self, AttachMode):  # String
		self.add_query_param('AttachMode', AttachMode)
