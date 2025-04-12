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

class SendDryRunSystemEventRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Cms', '2019-01-01', 'SendDryRunSystemEvent','cms')
		self.set_method('POST')

	def get_Product(self): # String
		return self.get_query_params().get('Product')

	def set_Product(self, Product):  # String
		self.add_query_param('Product', Product)
	def get_GroupId(self): # String
		return self.get_query_params().get('GroupId')

	def set_GroupId(self, GroupId):  # String
		self.add_query_param('GroupId', GroupId)
	def get_EventName(self): # String
		return self.get_query_params().get('EventName')

	def set_EventName(self, EventName):  # String
		self.add_query_param('EventName', EventName)
	def get_EventContent(self): # String
		return self.get_query_params().get('EventContent')

	def set_EventContent(self, EventContent):  # String
		self.add_query_param('EventContent', EventContent)
