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
from aliyunsdkcams.endpoint import endpoint_data
import json

class ListChatappTemplateRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'cams', '2020-06-06', 'ListChatappTemplate','cams')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_Code(self): # String
		return self.get_query_params().get('Code')

	def set_Code(self, Code):  # String
		self.add_query_param('Code', Code)
	def get_Language(self): # String
		return self.get_query_params().get('Language')

	def set_Language(self, Language):  # String
		self.add_query_param('Language', Language)
	def get_CustWabaId(self): # String
		return self.get_query_params().get('CustWabaId')

	def set_CustWabaId(self, CustWabaId):  # String
		self.add_query_param('CustWabaId', CustWabaId)
	def get_TemplateType(self): # String
		return self.get_query_params().get('TemplateType')

	def set_TemplateType(self, TemplateType):  # String
		self.add_query_param('TemplateType', TemplateType)
	def get_IsvCode(self): # String
		return self.get_query_params().get('IsvCode')

	def set_IsvCode(self, IsvCode):  # String
		self.add_query_param('IsvCode', IsvCode)
	def get_AuditStatus(self): # String
		return self.get_query_params().get('AuditStatus')

	def set_AuditStatus(self, AuditStatus):  # String
		self.add_query_param('AuditStatus', AuditStatus)
	def get_CustSpaceId(self): # String
		return self.get_query_params().get('CustSpaceId')

	def set_CustSpaceId(self, CustSpaceId):  # String
		self.add_query_param('CustSpaceId', CustSpaceId)
	def get_Name(self): # String
		return self.get_query_params().get('Name')

	def set_Name(self, Name):  # String
		self.add_query_param('Name', Name)
	def get_Page(self): # Struct
		return self.get_query_params().get('Page')

	def set_Page(self, Page):  # Struct
		self.add_query_param("Page", json.dumps(Page))
