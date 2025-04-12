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

class GetUserFinishedAdRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'imarketing', '2022-07-04', 'GetUserFinishedAd')
		self.set_method('GET')

	def get_Uid(self): # String
		return self.get_query_params().get('Uid')

	def set_Uid(self, Uid):  # String
		self.add_query_param('Uid', Uid)
	def get_Adid(self): # Long
		return self.get_query_params().get('Adid')

	def set_Adid(self, Adid):  # Long
		self.add_query_param('Adid', Adid)
	def get_Tagid(self): # String
		return self.get_query_params().get('Tagid')

	def set_Tagid(self, Tagid):  # String
		self.add_query_param('Tagid', Tagid)
	def get_Clicklink(self): # String
		return self.get_query_params().get('Clicklink')

	def set_Clicklink(self, Clicklink):  # String
		self.add_query_param('Clicklink', Clicklink)
	def get_Id(self): # String
		return self.get_query_params().get('Id')

	def set_Id(self, Id):  # String
		self.add_query_param('Id', Id)
	def get_Mediaid(self): # String
		return self.get_query_params().get('Mediaid')

	def set_Mediaid(self, Mediaid):  # String
		self.add_query_param('Mediaid', Mediaid)
