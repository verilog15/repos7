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

class CreatePublishGroupTaskRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'dms-enterprise', '2018-11-01', 'CreatePublishGroupTask','dms-enterprise')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_Tid(self): # Long
		return self.get_query_params().get('Tid')

	def set_Tid(self, Tid):  # Long
		self.add_query_param('Tid', Tid)
	def get_PlanTime(self): # String
		return self.get_query_params().get('PlanTime')

	def set_PlanTime(self, PlanTime):  # String
		self.add_query_param('PlanTime', PlanTime)
	def get_PublishStrategy(self): # String
		return self.get_query_params().get('PublishStrategy')

	def set_PublishStrategy(self, PublishStrategy):  # String
		self.add_query_param('PublishStrategy', PublishStrategy)
	def get_OrderId(self): # Long
		return self.get_query_params().get('OrderId')

	def set_OrderId(self, OrderId):  # Long
		self.add_query_param('OrderId', OrderId)
	def get_DbId(self): # Integer
		return self.get_query_params().get('DbId')

	def set_DbId(self, DbId):  # Integer
		self.add_query_param('DbId', DbId)
	def get_Logic(self): # Boolean
		return self.get_query_params().get('Logic')

	def set_Logic(self, Logic):  # Boolean
		self.add_query_param('Logic', Logic)
