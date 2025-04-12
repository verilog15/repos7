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
from aliyunsdkreid_cloud.endpoint import endpoint_data

class PullActionDataRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'reid_cloud', '2020-10-29', 'PullActionData','1.2.2')
		self.set_method('POST')
		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())


	def get_PartitionIndex(self):
		return self.get_body_params().get('PartitionIndex')

	def set_PartitionIndex(self,PartitionIndex):
		self.add_body_params('PartitionIndex', PartitionIndex)

	def get_StoreId(self):
		return self.get_body_params().get('StoreId')

	def set_StoreId(self,StoreId):
		self.add_body_params('StoreId', StoreId)

	def get_EndMessageId(self):
		return self.get_body_params().get('EndMessageId')

	def set_EndMessageId(self,EndMessageId):
		self.add_body_params('EndMessageId', EndMessageId)

	def get_Limit(self):
		return self.get_body_params().get('Limit')

	def set_Limit(self,Limit):
		self.add_body_params('Limit', Limit)

	def get_StartMessageId(self):
		return self.get_body_params().get('StartMessageId')

	def set_StartMessageId(self,StartMessageId):
		self.add_body_params('StartMessageId', StartMessageId)