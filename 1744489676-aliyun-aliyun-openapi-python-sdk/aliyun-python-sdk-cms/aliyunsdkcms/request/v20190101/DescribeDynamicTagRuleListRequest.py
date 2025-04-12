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

class DescribeDynamicTagRuleListRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Cms', '2019-01-01', 'DescribeDynamicTagRuleList','cms')
		self.set_method('POST')

	def get_TagValue(self): # String
		return self.get_query_params().get('TagValue')

	def set_TagValue(self, TagValue):  # String
		self.add_query_param('TagValue', TagValue)
	def get_DynamicTagRuleId(self): # String
		return self.get_query_params().get('DynamicTagRuleId')

	def set_DynamicTagRuleId(self, DynamicTagRuleId):  # String
		self.add_query_param('DynamicTagRuleId', DynamicTagRuleId)
	def get_PageNumber(self): # String
		return self.get_query_params().get('PageNumber')

	def set_PageNumber(self, PageNumber):  # String
		self.add_query_param('PageNumber', PageNumber)
	def get_PageSize(self): # String
		return self.get_query_params().get('PageSize')

	def set_PageSize(self, PageSize):  # String
		self.add_query_param('PageSize', PageSize)
	def get_TagKey(self): # String
		return self.get_query_params().get('TagKey')

	def set_TagKey(self, TagKey):  # String
		self.add_query_param('TagKey', TagKey)
	def get_TagRegionId(self): # String
		return self.get_query_params().get('TagRegionId')

	def set_TagRegionId(self, TagRegionId):  # String
		self.add_query_param('TagRegionId', TagRegionId)
