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

class DeleteAuthorizationRuleRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'CC5G', '2022-03-14', 'DeleteAuthorizationRule','fivegcc')
		self.set_method('POST')

	def get_DryRun(self): # Boolean
		return self.get_query_params().get('DryRun')

	def set_DryRun(self, DryRun):  # Boolean
		self.add_query_param('DryRun', DryRun)
	def get_ClientToken(self): # String
		return self.get_query_params().get('ClientToken')

	def set_ClientToken(self, ClientToken):  # String
		self.add_query_param('ClientToken', ClientToken)
	def get_AuthorizationRuleId(self): # String
		return self.get_query_params().get('AuthorizationRuleId')

	def set_AuthorizationRuleId(self, AuthorizationRuleId):  # String
		self.add_query_param('AuthorizationRuleId', AuthorizationRuleId)
	def get_WirelessCloudConnectorId(self): # String
		return self.get_query_params().get('WirelessCloudConnectorId')

	def set_WirelessCloudConnectorId(self, WirelessCloudConnectorId):  # String
		self.add_query_param('WirelessCloudConnectorId', WirelessCloudConnectorId)
