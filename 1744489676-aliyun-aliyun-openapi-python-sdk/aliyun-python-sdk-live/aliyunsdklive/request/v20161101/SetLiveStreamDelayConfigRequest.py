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

class SetLiveStreamDelayConfigRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'live', '2016-11-01', 'SetLiveStreamDelayConfig','live')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_FlvLevel(self): # String
		return self.get_query_params().get('FlvLevel')

	def set_FlvLevel(self, FlvLevel):  # String
		self.add_query_param('FlvLevel', FlvLevel)
	def get_HlsLevel(self): # String
		return self.get_query_params().get('HlsLevel')

	def set_HlsLevel(self, HlsLevel):  # String
		self.add_query_param('HlsLevel', HlsLevel)
	def get_RtmpDelay(self): # Integer
		return self.get_query_params().get('RtmpDelay')

	def set_RtmpDelay(self, RtmpDelay):  # Integer
		self.add_query_param('RtmpDelay', RtmpDelay)
	def get_DomainName(self): # String
		return self.get_query_params().get('DomainName')

	def set_DomainName(self, DomainName):  # String
		self.add_query_param('DomainName', DomainName)
	def get_OwnerId(self): # Long
		return self.get_query_params().get('OwnerId')

	def set_OwnerId(self, OwnerId):  # Long
		self.add_query_param('OwnerId', OwnerId)
	def get_FlvDelay(self): # Integer
		return self.get_query_params().get('FlvDelay')

	def set_FlvDelay(self, FlvDelay):  # Integer
		self.add_query_param('FlvDelay', FlvDelay)
	def get_RtmpLevel(self): # String
		return self.get_query_params().get('RtmpLevel')

	def set_RtmpLevel(self, RtmpLevel):  # String
		self.add_query_param('RtmpLevel', RtmpLevel)
	def get_HlsDelay(self): # Integer
		return self.get_query_params().get('HlsDelay')

	def set_HlsDelay(self, HlsDelay):  # Integer
		self.add_query_param('HlsDelay', HlsDelay)
