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

class MergeVideoFaceRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'videoenhan', '2020-03-20', 'MergeVideoFace','videoenhan')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_ReferenceURL(self): # String
		return self.get_body_params().get('ReferenceURL')

	def set_ReferenceURL(self, ReferenceURL):  # String
		self.add_body_params('ReferenceURL', ReferenceURL)
	def get_WatermarkType(self): # String
		return self.get_body_params().get('WatermarkType')

	def set_WatermarkType(self, WatermarkType):  # String
		self.add_body_params('WatermarkType', WatermarkType)
	def get_Enhance(self): # Boolean
		return self.get_body_params().get('Enhance')

	def set_Enhance(self, Enhance):  # Boolean
		self.add_body_params('Enhance', Enhance)
	def get_VideoURL(self): # String
		return self.get_body_params().get('VideoURL')

	def set_VideoURL(self, VideoURL):  # String
		self.add_body_params('VideoURL', VideoURL)
	def get_AddWatermark(self): # Boolean
		return self.get_body_params().get('AddWatermark')

	def set_AddWatermark(self, AddWatermark):  # Boolean
		self.add_body_params('AddWatermark', AddWatermark)
