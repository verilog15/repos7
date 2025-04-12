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
from aliyunsdkidaas_doraemon.endpoint import endpoint_data

class ListAuthenticationLogsRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'idaas-doraemon', '2021-05-20', 'ListAuthenticationLogs','idaasauth')
		self.set_protocol_type('https')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_ToTime(self): # Long
		return self.get_query_params().get('ToTime')

	def set_ToTime(self, ToTime):  # Long
		self.add_query_param('ToTime', ToTime)
	def get_UserId(self): # String
		return self.get_query_params().get('UserId')

	def set_UserId(self, UserId):  # String
		self.add_query_param('UserId', UserId)
	def get_LogTag(self): # String
		return self.get_query_params().get('LogTag')

	def set_LogTag(self, LogTag):  # String
		self.add_query_param('LogTag', LogTag)
	def get_PageNumber(self): # Long
		return self.get_query_params().get('PageNumber')

	def set_PageNumber(self, PageNumber):  # Long
		self.add_query_param('PageNumber', PageNumber)
	def get_PageSize(self): # Long
		return self.get_query_params().get('PageSize')

	def set_PageSize(self, PageSize):  # Long
		self.add_query_param('PageSize', PageSize)
	def get_CredentialId(self): # String
		return self.get_query_params().get('CredentialId')

	def set_CredentialId(self, CredentialId):  # String
		self.add_query_param('CredentialId', CredentialId)
	def get_FromTime(self): # Long
		return self.get_query_params().get('FromTime')

	def set_FromTime(self, FromTime):  # Long
		self.add_query_param('FromTime', FromTime)
	def get_AuthenticatorUuid(self): # String
		return self.get_query_params().get('AuthenticatorUuid')

	def set_AuthenticatorUuid(self, AuthenticatorUuid):  # String
		self.add_query_param('AuthenticatorUuid', AuthenticatorUuid)
	def get_AuthenticatorType(self): # String
		return self.get_query_params().get('AuthenticatorType')

	def set_AuthenticatorType(self, AuthenticatorType):  # String
		self.add_query_param('AuthenticatorType', AuthenticatorType)
	def get_ApplicationExternalId(self): # String
		return self.get_query_params().get('ApplicationExternalId')

	def set_ApplicationExternalId(self, ApplicationExternalId):  # String
		self.add_query_param('ApplicationExternalId', ApplicationExternalId)
