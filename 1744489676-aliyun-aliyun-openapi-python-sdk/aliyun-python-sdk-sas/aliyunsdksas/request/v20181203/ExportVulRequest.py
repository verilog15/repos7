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
from aliyunsdksas.endpoint import endpoint_data

class ExportVulRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Sas', '2018-12-03', 'ExportVul','sas')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_AttachTypes(self): # String
		return self.get_query_params().get('AttachTypes')

	def set_AttachTypes(self, AttachTypes):  # String
		self.add_query_param('AttachTypes', AttachTypes)
	def get_Type(self): # String
		return self.get_query_params().get('Type')

	def set_Type(self, Type):  # String
		self.add_query_param('Type', Type)
	def get_VpcInstanceIds(self): # String
		return self.get_query_params().get('VpcInstanceIds')

	def set_VpcInstanceIds(self, VpcInstanceIds):  # String
		self.add_query_param('VpcInstanceIds', VpcInstanceIds)
	def get_CreateTsStart(self): # Long
		return self.get_query_params().get('CreateTsStart')

	def set_CreateTsStart(self, CreateTsStart):  # Long
		self.add_query_param('CreateTsStart', CreateTsStart)
	def get_Path(self): # String
		return self.get_query_params().get('Path')

	def set_Path(self, Path):  # String
		self.add_query_param('Path', Path)
	def get_GroupId(self): # String
		return self.get_query_params().get('GroupId')

	def set_GroupId(self, GroupId):  # String
		self.add_query_param('GroupId', GroupId)
	def get_AliasName(self): # String
		return self.get_query_params().get('AliasName')

	def set_AliasName(self, AliasName):  # String
		self.add_query_param('AliasName', AliasName)
	def get_CreateTsEnd(self): # Long
		return self.get_query_params().get('CreateTsEnd')

	def set_CreateTsEnd(self, CreateTsEnd):  # Long
		self.add_query_param('CreateTsEnd', CreateTsEnd)
	def get_Necessity(self): # String
		return self.get_query_params().get('Necessity')

	def set_Necessity(self, Necessity):  # String
		self.add_query_param('Necessity', Necessity)
	def get_Uuids(self): # String
		return self.get_query_params().get('Uuids')

	def set_Uuids(self, Uuids):  # String
		self.add_query_param('Uuids', Uuids)
	def get_ContainerName(self): # String
		return self.get_query_params().get('ContainerName')

	def set_ContainerName(self, ContainerName):  # String
		self.add_query_param('ContainerName', ContainerName)
	def get_CveId(self): # String
		return self.get_query_params().get('CveId')

	def set_CveId(self, CveId):  # String
		self.add_query_param('CveId', CveId)
	def get_ImageName(self): # String
		return self.get_query_params().get('ImageName')

	def set_ImageName(self, ImageName):  # String
		self.add_query_param('ImageName', ImageName)
	def get_Lang(self): # String
		return self.get_query_params().get('Lang')

	def set_Lang(self, Lang):  # String
		self.add_query_param('Lang', Lang)
	def get_Dealed(self): # String
		return self.get_query_params().get('Dealed')

	def set_Dealed(self, Dealed):  # String
		self.add_query_param('Dealed', Dealed)
	def get_SearchTags(self): # String
		return self.get_query_params().get('SearchTags')

	def set_SearchTags(self, SearchTags):  # String
		self.add_query_param('SearchTags', SearchTags)
