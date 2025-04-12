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

class DescribeSplitItemBillRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'BssOpenApi', '2017-12-14', 'DescribeSplitItemBill','bssopenapi')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_ProductCode(self): # String
		return self.get_query_params().get('ProductCode')

	def set_ProductCode(self, ProductCode):  # String
		self.add_query_param('ProductCode', ProductCode)
	def get_IsHideZeroCharge(self): # Boolean
		return self.get_query_params().get('IsHideZeroCharge')

	def set_IsHideZeroCharge(self, IsHideZeroCharge):  # Boolean
		self.add_query_param('IsHideZeroCharge', IsHideZeroCharge)
	def get_SubscriptionType(self): # String
		return self.get_query_params().get('SubscriptionType')

	def set_SubscriptionType(self, SubscriptionType):  # String
		self.add_query_param('SubscriptionType', SubscriptionType)
	def get_BillOwnerId(self): # Long
		return self.get_query_params().get('BillOwnerId')

	def set_BillOwnerId(self, BillOwnerId):  # Long
		self.add_query_param('BillOwnerId', BillOwnerId)
	def get_ProductType(self): # String
		return self.get_query_params().get('ProductType')

	def set_ProductType(self, ProductType):  # String
		self.add_query_param('ProductType', ProductType)
	def get_NextToken(self): # String
		return self.get_query_params().get('NextToken')

	def set_NextToken(self, NextToken):  # String
		self.add_query_param('NextToken', NextToken)
	def get_SplitItemID(self): # String
		return self.get_query_params().get('SplitItemID')

	def set_SplitItemID(self, SplitItemID):  # String
		self.add_query_param('SplitItemID', SplitItemID)
	def get_BillingCycle(self): # String
		return self.get_query_params().get('BillingCycle')

	def set_BillingCycle(self, BillingCycle):  # String
		self.add_query_param('BillingCycle', BillingCycle)
	def get_OwnerId(self): # Long
		return self.get_query_params().get('OwnerId')

	def set_OwnerId(self, OwnerId):  # Long
		self.add_query_param('OwnerId', OwnerId)
	def get_TagFilters(self): # RepeatList
		return self.get_query_params().get('TagFilter')

	def set_TagFilters(self, TagFilter):  # RepeatList
		for depth1 in range(len(TagFilter)):
			if TagFilter[depth1].get('TagValues') is not None:
				for depth2 in range(len(TagFilter[depth1].get('TagValues'))):
					self.add_query_param('TagFilter.' + str(depth1 + 1) + '.TagValues.' + str(depth2 + 1), TagFilter[depth1].get('TagValues')[depth2])
			if TagFilter[depth1].get('TagKey') is not None:
				self.add_query_param('TagFilter.' + str(depth1 + 1) + '.TagKey', TagFilter[depth1].get('TagKey'))
	def get_BillingDate(self): # String
		return self.get_query_params().get('BillingDate')

	def set_BillingDate(self, BillingDate):  # String
		self.add_query_param('BillingDate', BillingDate)
	def get_InstanceID(self): # String
		return self.get_query_params().get('InstanceID')

	def set_InstanceID(self, InstanceID):  # String
		self.add_query_param('InstanceID', InstanceID)
	def get_Granularity(self): # String
		return self.get_query_params().get('Granularity')

	def set_Granularity(self, Granularity):  # String
		self.add_query_param('Granularity', Granularity)
	def get_MaxResults(self): # Integer
		return self.get_query_params().get('MaxResults')

	def set_MaxResults(self, MaxResults):  # Integer
		self.add_query_param('MaxResults', MaxResults)
	def get_PipCode(self): # String
		return self.get_query_params().get('PipCode')

	def set_PipCode(self, PipCode):  # String
		self.add_query_param('PipCode', PipCode)
