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
from aliyunsdkvs.endpoint import endpoint_data

class ContinuousMoveRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'vs', '2018-12-12', 'ContinuousMove')
		self.set_method('POST')
		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())


	def get_Tilt(self):
		return self.get_query_params().get('Tilt')

	def set_Tilt(self,Tilt):
		self.add_query_param('Tilt',Tilt)

	def get_SubProtocol(self):
		return self.get_query_params().get('SubProtocol')

	def set_SubProtocol(self,SubProtocol):
		self.add_query_param('SubProtocol',SubProtocol)

	def get_Id(self):
		return self.get_query_params().get('Id')

	def set_Id(self,Id):
		self.add_query_param('Id',Id)

	def get_Pan(self):
		return self.get_query_params().get('Pan')

	def set_Pan(self,Pan):
		self.add_query_param('Pan',Pan)

	def get_Zoom(self):
		return self.get_query_params().get('Zoom')

	def set_Zoom(self,Zoom):
		self.add_query_param('Zoom',Zoom)

	def get_OwnerId(self):
		return self.get_query_params().get('OwnerId')

	def set_OwnerId(self,OwnerId):
		self.add_query_param('OwnerId',OwnerId)