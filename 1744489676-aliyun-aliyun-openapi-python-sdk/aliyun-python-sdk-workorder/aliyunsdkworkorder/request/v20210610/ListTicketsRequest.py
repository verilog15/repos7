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
from aliyunsdkworkorder.endpoint import endpoint_data

class ListTicketsRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Workorder', '2021-06-10', 'ListTickets')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_StatusLists(self): # RepeatList
		return self.get_body_params().get('StatusList')

	def set_StatusLists(self, StatusList):  # RepeatList
		for depth1 in range(len(StatusList)):
			self.add_body_params('StatusList.' + str(depth1 + 1), StatusList[depth1])
	def get_StartDate(self): # Long
		return self.get_body_params().get('StartDate')

	def set_StartDate(self, StartDate):  # Long
		self.add_body_params('StartDate', StartDate)
	def get_PageNumber(self): # Integer
		return self.get_query_params().get('PageNumber')

	def set_PageNumber(self, PageNumber):  # Integer
		self.add_query_param('PageNumber', PageNumber)
	def get_TicketIdList(self): # Array
		return self.get_body_params().get('TicketIdList')

	def set_TicketIdList(self, TicketIdList):  # Array
		for index1, value1 in enumerate(TicketIdList):
			self.add_body_params('TicketIdList.' + str(index1 + 1), value1)
	def get_EndDate(self): # Long
		return self.get_body_params().get('EndDate')

	def set_EndDate(self, EndDate):  # Long
		self.add_body_params('EndDate', EndDate)
	def get_PageSize(self): # Integer
		return self.get_query_params().get('PageSize')

	def set_PageSize(self, PageSize):  # Integer
		self.add_query_param('PageSize', PageSize)
	def get_Keyword(self): # String
		return self.get_body_params().get('Keyword')

	def set_Keyword(self, Keyword):  # String
		self.add_body_params('Keyword', Keyword)
	def get_TicketId(self): # String
		return self.get_body_params().get('TicketId')

	def set_TicketId(self, TicketId):  # String
		self.add_body_params('TicketId', TicketId)
