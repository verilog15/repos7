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
from aliyunsdksae.endpoint import endpoint_data

class UpdateNamespaceRequest(RoaRequest):

	def __init__(self):
		RoaRequest.__init__(self, 'sae', '2019-05-06', 'UpdateNamespace','serverless')
		self.set_uri_pattern('/pop/v1/paas/namespace')
		self.set_method('PUT')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_NamespaceName(self): # String
		return self.get_query_params().get('NamespaceName')

	def set_NamespaceName(self, NamespaceName):  # String
		self.add_query_param('NamespaceName', NamespaceName)
	def get_NamespaceDescription(self): # String
		return self.get_query_params().get('NamespaceDescription')

	def set_NamespaceDescription(self, NamespaceDescription):  # String
		self.add_query_param('NamespaceDescription', NamespaceDescription)
	def get_EnableMicroRegistration(self): # Boolean
		return self.get_query_params().get('EnableMicroRegistration')

	def set_EnableMicroRegistration(self, EnableMicroRegistration):  # Boolean
		self.add_query_param('EnableMicroRegistration', EnableMicroRegistration)
	def get_NamespaceId(self): # String
		return self.get_query_params().get('NamespaceId')

	def set_NamespaceId(self, NamespaceId):  # String
		self.add_query_param('NamespaceId', NamespaceId)
	def get_NameSpaceShortId(self): # String
		return self.get_query_params().get('NameSpaceShortId')

	def set_NameSpaceShortId(self, NameSpaceShortId):  # String
		self.add_query_param('NameSpaceShortId', NameSpaceShortId)
