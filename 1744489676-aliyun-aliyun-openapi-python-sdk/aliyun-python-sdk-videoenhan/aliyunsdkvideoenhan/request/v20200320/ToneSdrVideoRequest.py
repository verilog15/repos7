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

class ToneSdrVideoRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'videoenhan', '2020-03-20', 'ToneSdrVideo','videoenhan')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_Bitrate(self): # Integer
		return self.get_body_params().get('Bitrate')

	def set_Bitrate(self, Bitrate):  # Integer
		self.add_body_params('Bitrate', Bitrate)
	def get_RecolorModel(self): # String
		return self.get_body_params().get('RecolorModel')

	def set_RecolorModel(self, RecolorModel):  # String
		self.add_body_params('RecolorModel', RecolorModel)
	def get_VideoURL(self): # String
		return self.get_body_params().get('VideoURL')

	def set_VideoURL(self, VideoURL):  # String
		self.add_body_params('VideoURL', VideoURL)
