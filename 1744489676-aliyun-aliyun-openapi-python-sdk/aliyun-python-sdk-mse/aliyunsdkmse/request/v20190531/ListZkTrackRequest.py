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

class ListZkTrackRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'mse', '2019-05-31', 'ListZkTrack','mse')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_StartTs(self): # Long
		return self.get_query_params().get('StartTs')

	def set_StartTs(self, StartTs):  # Long
		self.add_query_param('StartTs', StartTs)
	def get_SessionId(self): # String
		return self.get_query_params().get('SessionId')

	def set_SessionId(self, SessionId):  # String
		self.add_query_param('SessionId', SessionId)
	def get_PageNum(self): # Long
		return self.get_query_params().get('PageNum')

	def set_PageNum(self, PageNum):  # Long
		self.add_query_param('PageNum', PageNum)
	def get_Path(self): # String
		return self.get_query_params().get('Path')

	def set_Path(self, Path):  # String
		self.add_query_param('Path', Path)
	def get_RequestPars(self): # String
		return self.get_query_params().get('RequestPars')

	def set_RequestPars(self, RequestPars):  # String
		self.add_query_param('RequestPars', RequestPars)
	def get_EndTs(self): # Long
		return self.get_query_params().get('EndTs')

	def set_EndTs(self, EndTs):  # Long
		self.add_query_param('EndTs', EndTs)
	def get_PageSize(self): # Long
		return self.get_query_params().get('PageSize')

	def set_PageSize(self, PageSize):  # Long
		self.add_query_param('PageSize', PageSize)
	def get_Reverse(self): # Boolean
		return self.get_query_params().get('Reverse')

	def set_Reverse(self, Reverse):  # Boolean
		self.add_query_param('Reverse', Reverse)
	def get_InstanceId(self): # String
		return self.get_query_params().get('InstanceId')

	def set_InstanceId(self, InstanceId):  # String
		self.add_query_param('InstanceId', InstanceId)
	def get_AcceptLanguage(self): # String
		return self.get_query_params().get('AcceptLanguage')

	def set_AcceptLanguage(self, AcceptLanguage):  # String
		self.add_query_param('AcceptLanguage', AcceptLanguage)
