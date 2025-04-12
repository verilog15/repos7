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

class QueryEvaluateListRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'BssOpenApi', '2017-12-14', 'QueryEvaluateList','bssopenapi')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_EndSearchTime(self): # String
		return self.get_query_params().get('EndSearchTime')

	def set_EndSearchTime(self, EndSearchTime):  # String
		self.add_query_param('EndSearchTime', EndSearchTime)
	def get_OutBizId(self): # String
		return self.get_query_params().get('OutBizId')

	def set_OutBizId(self, OutBizId):  # String
		self.add_query_param('OutBizId', OutBizId)
	def get_SortType(self): # Integer
		return self.get_query_params().get('SortType')

	def set_SortType(self, SortType):  # Integer
		self.add_query_param('SortType', SortType)
	def get_Type(self): # Integer
		return self.get_query_params().get('Type')

	def set_Type(self, Type):  # Integer
		self.add_query_param('Type', Type)
	def get_PageNum(self): # Integer
		return self.get_query_params().get('PageNum')

	def set_PageNum(self, PageNum):  # Integer
		self.add_query_param('PageNum', PageNum)
	def get_PageSize(self): # Integer
		return self.get_query_params().get('PageSize')

	def set_PageSize(self, PageSize):  # Integer
		self.add_query_param('PageSize', PageSize)
	def get_EndAmount(self): # Long
		return self.get_query_params().get('EndAmount')

	def set_EndAmount(self, EndAmount):  # Long
		self.add_query_param('EndAmount', EndAmount)
	def get_BillCycle(self): # String
		return self.get_query_params().get('BillCycle')

	def set_BillCycle(self, BillCycle):  # String
		self.add_query_param('BillCycle', BillCycle)
	def get_BizTypeLists(self): # RepeatList
		return self.get_query_params().get('BizTypeList')

	def set_BizTypeLists(self, BizTypeList):  # RepeatList
		for depth1 in range(len(BizTypeList)):
			self.add_query_param('BizTypeList.' + str(depth1 + 1), BizTypeList[depth1])
	def get_OwnerId(self): # Long
		return self.get_query_params().get('OwnerId')

	def set_OwnerId(self, OwnerId):  # Long
		self.add_query_param('OwnerId', OwnerId)
	def get_StartSearchTime(self): # String
		return self.get_query_params().get('StartSearchTime')

	def set_StartSearchTime(self, StartSearchTime):  # String
		self.add_query_param('StartSearchTime', StartSearchTime)
	def get_EndBizTime(self): # String
		return self.get_query_params().get('EndBizTime')

	def set_EndBizTime(self, EndBizTime):  # String
		self.add_query_param('EndBizTime', EndBizTime)
	def get_StartAmount(self): # Long
		return self.get_query_params().get('StartAmount')

	def set_StartAmount(self, StartAmount):  # Long
		self.add_query_param('StartAmount', StartAmount)
	def get_StartBizTime(self): # String
		return self.get_query_params().get('StartBizTime')

	def set_StartBizTime(self, StartBizTime):  # String
		self.add_query_param('StartBizTime', StartBizTime)
