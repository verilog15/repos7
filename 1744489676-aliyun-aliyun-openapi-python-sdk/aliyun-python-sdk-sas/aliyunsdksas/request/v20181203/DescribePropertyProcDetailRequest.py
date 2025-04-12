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

class DescribePropertyProcDetailRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Sas', '2018-12-03', 'DescribePropertyProcDetail','sas')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_Remark(self): # String
		return self.get_query_params().get('Remark')

	def set_Remark(self, Remark):  # String
		self.add_query_param('Remark', Remark)
	def get_Uuid(self): # String
		return self.get_query_params().get('Uuid')

	def set_Uuid(self, Uuid):  # String
		self.add_query_param('Uuid', Uuid)
	def get_Cmdline(self): # String
		return self.get_query_params().get('Cmdline')

	def set_Cmdline(self, Cmdline):  # String
		self.add_query_param('Cmdline', Cmdline)
	def get_PageSize(self): # Integer
		return self.get_query_params().get('PageSize')

	def set_PageSize(self, PageSize):  # Integer
		self.add_query_param('PageSize', PageSize)
	def get_ProcTimeStart(self): # Long
		return self.get_query_params().get('ProcTimeStart')

	def set_ProcTimeStart(self, ProcTimeStart):  # Long
		self.add_query_param('ProcTimeStart', ProcTimeStart)
	def get_CurrentPage(self): # Integer
		return self.get_query_params().get('CurrentPage')

	def set_CurrentPage(self, CurrentPage):  # Integer
		self.add_query_param('CurrentPage', CurrentPage)
	def get_ProcTimeEnd(self): # Long
		return self.get_query_params().get('ProcTimeEnd')

	def set_ProcTimeEnd(self, ProcTimeEnd):  # Long
		self.add_query_param('ProcTimeEnd', ProcTimeEnd)
	def get_Extend(self): # String
		return self.get_query_params().get('Extend')

	def set_Extend(self, Extend):  # String
		self.add_query_param('Extend', Extend)
	def get_Name(self): # String
		return self.get_query_params().get('Name')

	def set_Name(self, Name):  # String
		self.add_query_param('Name', Name)
	def get_User(self): # String
		return self.get_query_params().get('User')

	def set_User(self, User):  # String
		self.add_query_param('User', User)
