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
from aliyunsdklive.endpoint import endpoint_data

class SetLiveLazyPullStreamInfoConfigRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'live', '2016-11-01', 'SetLiveLazyPullStreamInfoConfig','live')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_AppName(self): # String
		return self.get_query_params().get('AppName')

	def set_AppName(self, AppName):  # String
		self.add_query_param('AppName', AppName)
	def get_DomainName(self): # String
		return self.get_query_params().get('DomainName')

	def set_DomainName(self, DomainName):  # String
		self.add_query_param('DomainName', DomainName)
	def get_PullDomainName(self): # String
		return self.get_query_params().get('PullDomainName')

	def set_PullDomainName(self, PullDomainName):  # String
		self.add_query_param('PullDomainName', PullDomainName)
	def get_OwnerId(self): # Long
		return self.get_query_params().get('OwnerId')

	def set_OwnerId(self, OwnerId):  # Long
		self.add_query_param('OwnerId', OwnerId)
	def get_PullAppName(self): # String
		return self.get_query_params().get('PullAppName')

	def set_PullAppName(self, PullAppName):  # String
		self.add_query_param('PullAppName', PullAppName)
	def get_TranscodeLazy(self): # String
		return self.get_query_params().get('TranscodeLazy')

	def set_TranscodeLazy(self, TranscodeLazy):  # String
		self.add_query_param('TranscodeLazy', TranscodeLazy)
	def get_PullProtocol(self): # String
		return self.get_query_params().get('PullProtocol')

	def set_PullProtocol(self, PullProtocol):  # String
		self.add_query_param('PullProtocol', PullProtocol)
