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
from aliyunsdkbssopenapi.endpoint import endpoint_data

class SubscribeBillToOSSRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'BssOpenApi', '2017-12-14', 'SubscribeBillToOSS','bssopenapi')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_BucketOwnerId(self): # Long
		return self.get_query_params().get('BucketOwnerId')

	def set_BucketOwnerId(self, BucketOwnerId):  # Long
		self.add_query_param('BucketOwnerId', BucketOwnerId)
	def get_SubscribeType(self): # String
		return self.get_query_params().get('SubscribeType')

	def set_SubscribeType(self, SubscribeType):  # String
		self.add_query_param('SubscribeType', SubscribeType)
	def get_SubscribeBucket(self): # String
		return self.get_query_params().get('SubscribeBucket')

	def set_SubscribeBucket(self, SubscribeBucket):  # String
		self.add_query_param('SubscribeBucket', SubscribeBucket)
	def get_BucketPath(self): # String
		return self.get_query_params().get('BucketPath')

	def set_BucketPath(self, BucketPath):  # String
		self.add_query_param('BucketPath', BucketPath)
	def get_BeginBillingCycle(self): # String
		return self.get_query_params().get('BeginBillingCycle')

	def set_BeginBillingCycle(self, BeginBillingCycle):  # String
		self.add_query_param('BeginBillingCycle', BeginBillingCycle)
	def get_RowLimitPerFile(self): # Integer
		return self.get_query_params().get('RowLimitPerFile')

	def set_RowLimitPerFile(self, RowLimitPerFile):  # Integer
		self.add_query_param('RowLimitPerFile', RowLimitPerFile)
	def get_MultAccountRelSubscribe(self): # String
		return self.get_query_params().get('MultAccountRelSubscribe')

	def set_MultAccountRelSubscribe(self, MultAccountRelSubscribe):  # String
		self.add_query_param('MultAccountRelSubscribe', MultAccountRelSubscribe)
