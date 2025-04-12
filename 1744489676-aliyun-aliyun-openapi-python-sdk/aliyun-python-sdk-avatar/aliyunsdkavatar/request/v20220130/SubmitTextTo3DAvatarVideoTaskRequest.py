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
import json

class SubmitTextTo3DAvatarVideoTaskRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'avatar', '2022-01-30', 'SubmitTextTo3DAvatarVideoTask')
		self.set_method('POST')

	def get_App(self): # Struct
		return self.get_query_params().get('App')

	def set_App(self, App):  # Struct
		self.add_query_param("App", json.dumps(App))
	def get_AudioInfo(self): # Struct
		return self.get_query_params().get('AudioInfo')

	def set_AudioInfo(self, AudioInfo):  # Struct
		self.add_query_param("AudioInfo", json.dumps(AudioInfo))
	def get_AvatarInfo(self): # Struct
		return self.get_query_params().get('AvatarInfo')

	def set_AvatarInfo(self, AvatarInfo):  # Struct
		self.add_query_param("AvatarInfo", json.dumps(AvatarInfo))
	def get_Title(self): # String
		return self.get_query_params().get('Title')

	def set_Title(self, Title):  # String
		self.add_query_param('Title', Title)
	def get_ExtParams(self): # String
		return self.get_query_params().get('ExtParams')

	def set_ExtParams(self, ExtParams):  # String
		self.add_query_param('ExtParams', ExtParams)
	def get_VideoInfo(self): # Struct
		return self.get_query_params().get('VideoInfo')

	def set_VideoInfo(self, VideoInfo):  # Struct
		self.add_query_param("VideoInfo", json.dumps(VideoInfo))
	def get_CallbackParams(self): # String
		return self.get_query_params().get('CallbackParams')

	def set_CallbackParams(self, CallbackParams):  # String
		self.add_query_param('CallbackParams', CallbackParams)
	def get_TenantId(self): # Long
		return self.get_query_params().get('TenantId')

	def set_TenantId(self, TenantId):  # Long
		self.add_query_param('TenantId', TenantId)
	def get_Callback(self): # Boolean
		return self.get_query_params().get('Callback')

	def set_Callback(self, Callback):  # Boolean
		self.add_query_param('Callback', Callback)
	def get_Text(self): # String
		return self.get_query_params().get('Text')

	def set_Text(self, Text):  # String
		self.add_query_param('Text', Text)
