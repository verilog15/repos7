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
from aliyunsdkemr.endpoint import endpoint_data

class DescribeFlowCategoryTreeRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Emr', '2016-04-08', 'DescribeFlowCategoryTree')
		self.set_method('POST')
		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())


	def get_Type(self):
		return self.get_query_params().get('Type')

	def set_Type(self,Type):
		self.add_query_param('Type',Type)

	def get_Mode(self):
		return self.get_query_params().get('Mode')

	def set_Mode(self,Mode):
		self.add_query_param('Mode',Mode)

	def get_Keyword(self):
		return self.get_query_params().get('Keyword')

	def set_Keyword(self,Keyword):
		self.add_query_param('Keyword',Keyword)

	def get_ProjectId(self):
		return self.get_query_params().get('ProjectId')

	def set_ProjectId(self,ProjectId):
		self.add_query_param('ProjectId',ProjectId)

	def get_CategoryId(self):
		return self.get_query_params().get('CategoryId')

	def set_CategoryId(self,CategoryId):
		self.add_query_param('CategoryId',CategoryId)