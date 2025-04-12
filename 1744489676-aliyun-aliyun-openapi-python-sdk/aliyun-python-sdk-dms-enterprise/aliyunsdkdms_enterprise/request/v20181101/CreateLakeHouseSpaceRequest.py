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
from aliyunsdkdms_enterprise.endpoint import endpoint_data

class CreateLakeHouseSpaceRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'dms-enterprise', '2018-11-01', 'CreateLakeHouseSpace','dms-enterprise')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_Description(self): # String
		return self.get_query_params().get('Description')

	def set_Description(self, Description):  # String
		self.add_query_param('Description', Description)
	def get_Tid(self): # Long
		return self.get_query_params().get('Tid')

	def set_Tid(self, Tid):  # Long
		self.add_query_param('Tid', Tid)
	def get_Mode(self): # String
		return self.get_query_params().get('Mode')

	def set_Mode(self, Mode):  # String
		self.add_query_param('Mode', Mode)
	def get_ProdDbId(self): # String
		return self.get_query_params().get('ProdDbId')

	def set_ProdDbId(self, ProdDbId):  # String
		self.add_query_param('ProdDbId', ProdDbId)
	def get_DevDbId(self): # String
		return self.get_query_params().get('DevDbId')

	def set_DevDbId(self, DevDbId):  # String
		self.add_query_param('DevDbId', DevDbId)
	def get_SpaceName(self): # String
		return self.get_query_params().get('SpaceName')

	def set_SpaceName(self, SpaceName):  # String
		self.add_query_param('SpaceName', SpaceName)
	def get_DwDbType(self): # String
		return self.get_query_params().get('DwDbType')

	def set_DwDbType(self, DwDbType):  # String
		self.add_query_param('DwDbType', DwDbType)
	def get_SpaceConfig(self): # String
		return self.get_query_params().get('SpaceConfig')

	def set_SpaceConfig(self, SpaceConfig):  # String
		self.add_query_param('SpaceConfig', SpaceConfig)
