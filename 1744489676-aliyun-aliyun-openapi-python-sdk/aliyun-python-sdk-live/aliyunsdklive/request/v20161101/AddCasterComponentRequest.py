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

class AddCasterComponentRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'live', '2016-11-01', 'AddCasterComponent','live')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_HtmlLayerContent(self): # String
		return self.get_query_params().get('HtmlLayerContent')

	def set_HtmlLayerContent(self, HtmlLayerContent):  # String
		self.add_query_param('HtmlLayerContent', HtmlLayerContent)
	def get_ImageLayerContent(self): # String
		return self.get_query_params().get('ImageLayerContent')

	def set_ImageLayerContent(self, ImageLayerContent):  # String
		self.add_query_param('ImageLayerContent', ImageLayerContent)
	def get_ComponentName(self): # String
		return self.get_query_params().get('ComponentName')

	def set_ComponentName(self, ComponentName):  # String
		self.add_query_param('ComponentName', ComponentName)
	def get_LayerOrder(self): # String
		return self.get_query_params().get('LayerOrder')

	def set_LayerOrder(self, LayerOrder):  # String
		self.add_query_param('LayerOrder', LayerOrder)
	def get_CasterId(self): # String
		return self.get_query_params().get('CasterId')

	def set_CasterId(self, CasterId):  # String
		self.add_query_param('CasterId', CasterId)
	def get_ComponentLayer(self): # String
		return self.get_query_params().get('ComponentLayer')

	def set_ComponentLayer(self, ComponentLayer):  # String
		self.add_query_param('ComponentLayer', ComponentLayer)
	def get_OwnerId(self): # Long
		return self.get_query_params().get('OwnerId')

	def set_OwnerId(self, OwnerId):  # Long
		self.add_query_param('OwnerId', OwnerId)
	def get_ComponentType(self): # String
		return self.get_query_params().get('ComponentType')

	def set_ComponentType(self, ComponentType):  # String
		self.add_query_param('ComponentType', ComponentType)
	def get_LocationId(self): # String
		return self.get_query_params().get('LocationId')

	def set_LocationId(self, LocationId):  # String
		self.add_query_param('LocationId', LocationId)
	def get_Effect(self): # String
		return self.get_query_params().get('Effect')

	def set_Effect(self, Effect):  # String
		self.add_query_param('Effect', Effect)
	def get_CaptionLayerContent(self): # String
		return self.get_query_params().get('CaptionLayerContent')

	def set_CaptionLayerContent(self, CaptionLayerContent):  # String
		self.add_query_param('CaptionLayerContent', CaptionLayerContent)
	def get_TextLayerContent(self): # String
		return self.get_query_params().get('TextLayerContent')

	def set_TextLayerContent(self, TextLayerContent):  # String
		self.add_query_param('TextLayerContent', TextLayerContent)
