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
from aliyunsdkdms_enterprise.endpoint import endpoint_data

class ApproveOrderRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'dms-enterprise', '2018-11-01', 'ApproveOrder','dms-enterprise')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_Tid(self): # Long
		return self.get_query_params().get('Tid')

	def set_Tid(self, Tid):  # Long
		self.add_query_param('Tid', Tid)
	def get_WorkflowInstanceId(self): # Long
		return self.get_query_params().get('WorkflowInstanceId')

	def set_WorkflowInstanceId(self, WorkflowInstanceId):  # Long
		self.add_query_param('WorkflowInstanceId', WorkflowInstanceId)
	def get_ApprovalType(self): # String
		return self.get_query_params().get('ApprovalType')

	def set_ApprovalType(self, ApprovalType):  # String
		self.add_query_param('ApprovalType', ApprovalType)
	def get_NewApprover(self): # Long
		return self.get_query_params().get('NewApprover')

	def set_NewApprover(self, NewApprover):  # Long
		self.add_query_param('NewApprover', NewApprover)
	def get_ApprovalNodeId(self): # Long
		return self.get_query_params().get('ApprovalNodeId')

	def set_ApprovalNodeId(self, ApprovalNodeId):  # Long
		self.add_query_param('ApprovalNodeId', ApprovalNodeId)
	def get_OldApprover(self): # Long
		return self.get_query_params().get('OldApprover')

	def set_OldApprover(self, OldApprover):  # Long
		self.add_query_param('OldApprover', OldApprover)
	def get_RealLoginUserUid(self): # String
		return self.get_query_params().get('RealLoginUserUid')

	def set_RealLoginUserUid(self, RealLoginUserUid):  # String
		self.add_query_param('RealLoginUserUid', RealLoginUserUid)
	def get_Comment(self): # String
		return self.get_query_params().get('Comment')

	def set_Comment(self, Comment):  # String
		self.add_query_param('Comment', Comment)
	def get_ApprovalNodePos(self): # String
		return self.get_query_params().get('ApprovalNodePos')

	def set_ApprovalNodePos(self, ApprovalNodePos):  # String
		self.add_query_param('ApprovalNodePos', ApprovalNodePos)
	def get_NewApproverList(self): # String
		return self.get_query_params().get('NewApproverList')

	def set_NewApproverList(self, NewApproverList):  # String
		self.add_query_param('NewApproverList', NewApproverList)
