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

class PutContactRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Cms', '2019-01-01', 'PutContact','cms')
		self.set_method('POST')

	def get_ChannelsDingWebHook(self): # String
		return self.get_query_params().get('Channels.DingWebHook')

	def set_ChannelsDingWebHook(self, ChannelsDingWebHook):  # String
		self.add_query_param('Channels.DingWebHook', ChannelsDingWebHook)
	def get_ContactName(self): # String
		return self.get_query_params().get('ContactName')

	def set_ContactName(self, ContactName):  # String
		self.add_query_param('ContactName', ContactName)
	def get_ChannelsMail(self): # String
		return self.get_query_params().get('Channels.Mail')

	def set_ChannelsMail(self, ChannelsMail):  # String
		self.add_query_param('Channels.Mail', ChannelsMail)
	def get_ChannelsAliIM(self): # String
		return self.get_query_params().get('Channels.AliIM')

	def set_ChannelsAliIM(self, ChannelsAliIM):  # String
		self.add_query_param('Channels.AliIM', ChannelsAliIM)
	def get_Describe(self): # String
		return self.get_query_params().get('Describe')

	def set_Describe(self, Describe):  # String
		self.add_query_param('Describe', Describe)
	def get_Lang(self): # String
		return self.get_query_params().get('Lang')

	def set_Lang(self, Lang):  # String
		self.add_query_param('Lang', Lang)
	def get_ChannelsSMS(self): # String
		return self.get_query_params().get('Channels.SMS')

	def set_ChannelsSMS(self, ChannelsSMS):  # String
		self.add_query_param('Channels.SMS', ChannelsSMS)
