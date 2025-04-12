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

class EnhanceVideoQualityRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'videoenhan', '2020-03-20', 'EnhanceVideoQuality','videoenhan')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_HDRFormat(self): # String
		return self.get_body_params().get('HDRFormat')

	def set_HDRFormat(self, HDRFormat):  # String
		self.add_body_params('HDRFormat', HDRFormat)
	def get_FrameRate(self): # Integer
		return self.get_body_params().get('FrameRate')

	def set_FrameRate(self, FrameRate):  # Integer
		self.add_body_params('FrameRate', FrameRate)
	def get_MaxIlluminance(self): # Integer
		return self.get_body_params().get('MaxIlluminance')

	def set_MaxIlluminance(self, MaxIlluminance):  # Integer
		self.add_body_params('MaxIlluminance', MaxIlluminance)
	def get_Bitrate(self): # Integer
		return self.get_body_params().get('Bitrate')

	def set_Bitrate(self, Bitrate):  # Integer
		self.add_body_params('Bitrate', Bitrate)
	def get_OutPutWidth(self): # Integer
		return self.get_body_params().get('OutPutWidth')

	def set_OutPutWidth(self, OutPutWidth):  # Integer
		self.add_body_params('OutPutWidth', OutPutWidth)
	def get_OutPutHeight(self): # Integer
		return self.get_body_params().get('OutPutHeight')

	def set_OutPutHeight(self, OutPutHeight):  # Integer
		self.add_body_params('OutPutHeight', OutPutHeight)
	def get_VideoURL(self): # String
		return self.get_body_params().get('VideoURL')

	def set_VideoURL(self, VideoURL):  # String
		self.add_body_params('VideoURL', VideoURL)
