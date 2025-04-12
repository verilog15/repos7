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

class QuerySettleBillRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'BssOpenApi', '2017-12-14', 'QuerySettleBill','bssopenapi')
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
	def get_IsDisplayLocalCurrency(self): # Boolean
		return self.get_query_params().get('IsDisplayLocalCurrency')

	def set_IsDisplayLocalCurrency(self, IsDisplayLocalCurrency):  # Boolean
		self.add_query_param('IsDisplayLocalCurrency', IsDisplayLocalCurrency)
	def get_SubscriptionType(self): # String
		return self.get_query_params().get('SubscriptionType')

	def set_SubscriptionType(self, SubscriptionType):  # String
		self.add_query_param('SubscriptionType', SubscriptionType)
	def get_BillingCycle(self): # String
		return self.get_query_params().get('BillingCycle')

	def set_BillingCycle(self, BillingCycle):  # String
		self.add_query_param('BillingCycle', BillingCycle)
	def get_Type(self): # String
		return self.get_query_params().get('Type')

	def set_Type(self, Type):  # String
		self.add_query_param('Type', Type)
	def get_OwnerId(self): # Long
		return self.get_query_params().get('OwnerId')

	def set_OwnerId(self, OwnerId):  # Long
		self.add_query_param('OwnerId', OwnerId)
	def get_BillOwnerId(self): # Long
		return self.get_query_params().get('BillOwnerId')

	def set_BillOwnerId(self, BillOwnerId):  # Long
		self.add_query_param('BillOwnerId', BillOwnerId)
	def get_ProductType(self): # String
		return self.get_query_params().get('ProductType')

	def set_ProductType(self, ProductType):  # String
		self.add_query_param('ProductType', ProductType)
	def get_RecordID(self): # String
		return self.get_query_params().get('RecordID')

	def set_RecordID(self, RecordID):  # String
		self.add_query_param('RecordID', RecordID)
	def get_NextToken(self): # String
		return self.get_query_params().get('NextToken')

	def set_NextToken(self, NextToken):  # String
		self.add_query_param('NextToken', NextToken)
	def get_MaxResults(self): # Integer
		return self.get_query_params().get('MaxResults')

	def set_MaxResults(self, MaxResults):  # Integer
		self.add_query_param('MaxResults', MaxResults)
