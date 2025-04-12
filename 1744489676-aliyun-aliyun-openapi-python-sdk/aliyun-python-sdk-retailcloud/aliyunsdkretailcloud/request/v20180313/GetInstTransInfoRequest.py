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
from aliyunsdkretailcloud.endpoint import endpoint_data

class GetInstTransInfoRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'retailcloud', '2018-03-13', 'GetInstTransInfo')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_aliyunUid(self): # String
		return self.get_body_params().get('aliyunUid')

	def set_aliyunUid(self, aliyunUid):  # String
		self.add_body_params('aliyunUid', aliyunUid)
	def get_aliyunEquipId(self): # String
		return self.get_body_params().get('aliyunEquipId')

	def set_aliyunEquipId(self, aliyunEquipId):  # String
		self.add_body_params('aliyunEquipId', aliyunEquipId)
	def get_aliyunCommodityCode(self): # String
		return self.get_body_params().get('aliyunCommodityCode')

	def set_aliyunCommodityCode(self, aliyunCommodityCode):  # String
		self.add_body_params('aliyunCommodityCode', aliyunCommodityCode)
