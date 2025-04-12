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
from aliyunsdkmse.endpoint import endpoint_data

class CreateOrUpdateSwimmingLaneGroupRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'mse', '2019-05-31', 'CreateOrUpdateSwimmingLaneGroup','mse')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_AppIds(self): # String
		return self.get_query_params().get('AppIds')

	def set_AppIds(self, AppIds):  # String
		self.add_query_param('AppIds', AppIds)
	def get_DbGrayEnable(self): # Boolean
		return self.get_query_params().get('DbGrayEnable')

	def set_DbGrayEnable(self, DbGrayEnable):  # Boolean
		self.add_query_param('DbGrayEnable', DbGrayEnable)
	def get_Id(self): # Long
		return self.get_query_params().get('Id')

	def set_Id(self, Id):  # Long
		self.add_query_param('Id', Id)
	def get_Name(self): # String
		return self.get_query_params().get('Name')

	def set_Name(self, Name):  # String
		self.add_query_param('Name', Name)
	def get_MessageQueueFilterSide(self): # String
		return self.get_query_params().get('MessageQueueFilterSide')

	def set_MessageQueueFilterSide(self, MessageQueueFilterSide):  # String
		self.add_query_param('MessageQueueFilterSide', MessageQueueFilterSide)
	def get_Region(self): # String
		return self.get_query_params().get('Region')

	def set_Region(self, Region):  # String
		self.add_query_param('Region', Region)
	def get_Status(self): # Integer
		return self.get_query_params().get('Status')

	def set_Status(self, Status):  # Integer
		self.add_query_param('Status', Status)
	def get_MessageQueueGrayEnable(self): # Boolean
		return self.get_query_params().get('MessageQueueGrayEnable')

	def set_MessageQueueGrayEnable(self, MessageQueueGrayEnable):  # Boolean
		self.add_query_param('MessageQueueGrayEnable', MessageQueueGrayEnable)
	def get_EntryApp(self): # String
		return self.get_query_params().get('EntryApp')

	def set_EntryApp(self, EntryApp):  # String
		self.add_query_param('EntryApp', EntryApp)
	def get_RecordCanaryDetail(self): # Boolean
		return self.get_query_params().get('RecordCanaryDetail')

	def set_RecordCanaryDetail(self, RecordCanaryDetail):  # Boolean
		self.add_query_param('RecordCanaryDetail', RecordCanaryDetail)
	def get_Namespace(self): # String
		return self.get_query_params().get('Namespace')

	def set_Namespace(self, Namespace):  # String
		self.add_query_param('Namespace', Namespace)
	def get_AcceptLanguage(self): # String
		return self.get_query_params().get('AcceptLanguage')

	def set_AcceptLanguage(self, AcceptLanguage):  # String
		self.add_query_param('AcceptLanguage', AcceptLanguage)
