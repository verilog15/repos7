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

class DescribeVulListRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Sas', '2018-12-03', 'DescribeVulList','sas')
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
	def get_UseNextToken(self): # Boolean
		return self.get_query_params().get('UseNextToken')

	def set_UseNextToken(self, UseNextToken):  # Boolean
		self.add_query_param('UseNextToken', UseNextToken)
	def get_GroupId(self): # String
		return self.get_query_params().get('GroupId')

	def set_GroupId(self, GroupId):  # String
		self.add_query_param('GroupId', GroupId)
	def get_AliasName(self): # String
		return self.get_query_params().get('AliasName')

	def set_AliasName(self, AliasName):  # String
		self.add_query_param('AliasName', AliasName)
	def get_Name(self): # String
		return self.get_query_params().get('Name')

	def set_Name(self, Name):  # String
		self.add_query_param('Name', Name)
	def get_Necessity(self): # String
		return self.get_query_params().get('Necessity')

	def set_Necessity(self, Necessity):  # String
		self.add_query_param('Necessity', Necessity)
	def get_Uuids(self): # String
		return self.get_query_params().get('Uuids')

	def set_Uuids(self, Uuids):  # String
		self.add_query_param('Uuids', Uuids)
	def get_StatusList(self): # String
		return self.get_query_params().get('StatusList')

	def set_StatusList(self, StatusList):  # String
		self.add_query_param('StatusList', StatusList)
	def get_Remark(self): # String
		return self.get_query_params().get('Remark')

	def set_Remark(self, Remark):  # String
		self.add_query_param('Remark', Remark)
	def get_NextToken(self): # String
		return self.get_query_params().get('NextToken')

	def set_NextToken(self, NextToken):  # String
		self.add_query_param('NextToken', NextToken)
	def get_PageSize(self): # Integer
		return self.get_query_params().get('PageSize')

	def set_PageSize(self, PageSize):  # Integer
		self.add_query_param('PageSize', PageSize)
	def get_Lang(self): # String
		return self.get_query_params().get('Lang')

	def set_Lang(self, Lang):  # String
		self.add_query_param('Lang', Lang)
	def get_ResourceDirectoryAccountId(self): # Long
		return self.get_query_params().get('ResourceDirectoryAccountId')

	def set_ResourceDirectoryAccountId(self, ResourceDirectoryAccountId):  # Long
		self.add_query_param('ResourceDirectoryAccountId', ResourceDirectoryAccountId)
	def get_Dealed(self): # String
		return self.get_query_params().get('Dealed')

	def set_Dealed(self, Dealed):  # String
		self.add_query_param('Dealed', Dealed)
	def get_CurrentPage(self): # Integer
		return self.get_query_params().get('CurrentPage')

	def set_CurrentPage(self, CurrentPage):  # Integer
		self.add_query_param('CurrentPage', CurrentPage)
