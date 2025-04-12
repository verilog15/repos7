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

class StopGatewayRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'dms-dg', '2023-09-14', 'StopGateway')
		self.set_protocol_type('https')
		self.set_method('POST')

	def get_GatewayInstanceId(self): # String
		return self.get_body_params().get('GatewayInstanceId')

	def set_GatewayInstanceId(self, GatewayInstanceId):  # String
		self.add_body_params('GatewayInstanceId', GatewayInstanceId)
	def get_GatewayId(self): # String
		return self.get_body_params().get('GatewayId')

	def set_GatewayId(self, GatewayId):  # String
		self.add_body_params('GatewayId', GatewayId)
