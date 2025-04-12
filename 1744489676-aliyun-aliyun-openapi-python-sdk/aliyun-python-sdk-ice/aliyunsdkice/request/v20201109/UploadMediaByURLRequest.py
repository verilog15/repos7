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
from aliyunsdkice.endpoint import endpoint_data

class UploadMediaByURLRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'ICE', '2020-11-09', 'UploadMediaByURL','ice')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_EntityId(self): # String
		return self.get_query_params().get('EntityId')

	def set_EntityId(self, EntityId):  # String
		self.add_query_param('EntityId', EntityId)
	def get_UserData(self): # String
		return self.get_query_params().get('UserData')

	def set_UserData(self, UserData):  # String
		self.add_query_param('UserData', UserData)
	def get_MediaMetaData(self): # String
		return self.get_query_params().get('MediaMetaData')

	def set_MediaMetaData(self, MediaMetaData):  # String
		self.add_query_param('MediaMetaData', MediaMetaData)
	def get_PostProcessConfig(self): # String
		return self.get_query_params().get('PostProcessConfig')

	def set_PostProcessConfig(self, PostProcessConfig):  # String
		self.add_query_param('PostProcessConfig', PostProcessConfig)
	def get_UploadURLs(self): # String
		return self.get_query_params().get('UploadURLs')

	def set_UploadURLs(self, UploadURLs):  # String
		self.add_query_param('UploadURLs', UploadURLs)
	def get_AppId(self): # String
		return self.get_query_params().get('AppId')

	def set_AppId(self, AppId):  # String
		self.add_query_param('AppId', AppId)
	def get_UploadTargetConfig(self): # String
		return self.get_query_params().get('UploadTargetConfig')

	def set_UploadTargetConfig(self, UploadTargetConfig):  # String
		self.add_query_param('UploadTargetConfig', UploadTargetConfig)
