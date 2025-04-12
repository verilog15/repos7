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
from aliyunsdkretailcloud.endpoint import endpoint_data

class CreateDbRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'retailcloud', '2018-03-13', 'CreateDb')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_DbName(self): # String
		return self.get_body_params().get('DbName')

	def set_DbName(self, DbName):  # String
		self.add_body_params('DbName', DbName)
	def get_DbInstanceId(self): # String
		return self.get_body_params().get('DbInstanceId')

	def set_DbInstanceId(self, DbInstanceId):  # String
		self.add_body_params('DbInstanceId', DbInstanceId)
	def get_DbDescription(self): # String
		return self.get_body_params().get('DbDescription')

	def set_DbDescription(self, DbDescription):  # String
		self.add_body_params('DbDescription', DbDescription)
	def get_CharacterSetName(self): # String
		return self.get_body_params().get('CharacterSetName')

	def set_CharacterSetName(self, CharacterSetName):  # String
		self.add_body_params('CharacterSetName', CharacterSetName)
