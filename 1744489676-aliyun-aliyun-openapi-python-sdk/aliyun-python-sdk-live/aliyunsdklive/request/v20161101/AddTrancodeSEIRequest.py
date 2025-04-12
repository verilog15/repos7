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
from aliyunsdklive.endpoint import endpoint_data

class AddTrancodeSEIRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'live', '2016-11-01', 'AddTrancodeSEI','live')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_Pattern(self): # String
		return self.get_query_params().get('Pattern')

	def set_Pattern(self, Pattern):  # String
		self.add_query_param('Pattern', Pattern)
	def get_AppName(self): # String
		return self.get_query_params().get('AppName')

	def set_AppName(self, AppName):  # String
		self.add_query_param('AppName', AppName)
	def get_Repeat(self): # Integer
		return self.get_query_params().get('Repeat')

	def set_Repeat(self, Repeat):  # Integer
		self.add_query_param('Repeat', Repeat)
	def get_Text(self): # String
		return self.get_query_params().get('Text')

	def set_Text(self, Text):  # String
		self.add_query_param('Text', Text)
	def get_StreamName(self): # String
		return self.get_query_params().get('StreamName')

	def set_StreamName(self, StreamName):  # String
		self.add_query_param('StreamName', StreamName)
	def get_DomainName(self): # String
		return self.get_query_params().get('DomainName')

	def set_DomainName(self, DomainName):  # String
		self.add_query_param('DomainName', DomainName)
	def get_OwnerId(self): # Long
		return self.get_query_params().get('OwnerId')

	def set_OwnerId(self, OwnerId):  # Long
		self.add_query_param('OwnerId', OwnerId)
	def get_Delay(self): # Integer
		return self.get_query_params().get('Delay')

	def set_Delay(self, Delay):  # Integer
		self.add_query_param('Delay', Delay)
