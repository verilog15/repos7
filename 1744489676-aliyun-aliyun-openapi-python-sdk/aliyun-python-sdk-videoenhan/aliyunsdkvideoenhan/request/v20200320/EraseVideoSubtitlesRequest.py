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
from aliyunsdkvideoenhan.endpoint import endpoint_data

class EraseVideoSubtitlesRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'videoenhan', '2020-03-20', 'EraseVideoSubtitles','videoenhan')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_BH(self): # Float
		return self.get_body_params().get('BH')

	def set_BH(self, BH):  # Float
		self.add_body_params('BH', BH)
	def get_BW(self): # Float
		return self.get_body_params().get('BW')

	def set_BW(self, BW):  # Float
		self.add_body_params('BW', BW)
	def get_BX(self): # Float
		return self.get_body_params().get('BX')

	def set_BX(self, BX):  # Float
		self.add_body_params('BX', BX)
	def get_BY(self): # Float
		return self.get_body_params().get('BY')

	def set_BY(self, BY):  # Float
		self.add_body_params('BY', BY)
	def get_VideoUrl(self): # String
		return self.get_body_params().get('VideoUrl')

	def set_VideoUrl(self, VideoUrl):  # String
		self.add_body_params('VideoUrl', VideoUrl)
