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

class RecognizeImageRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'CDRS', '2020-11-01', 'RecognizeImage')
		self.set_method('POST')

	def get_RequireCropImage(self):
		return self.get_body_params().get('RequireCropImage')

	def set_RequireCropImage(self,RequireCropImage):
		self.add_body_params('RequireCropImage', RequireCropImage)

	def get_CorpId(self):
		return self.get_body_params().get('CorpId')

	def set_CorpId(self,CorpId):
		self.add_body_params('CorpId', CorpId)

	def get_RecognizeType(self):
		return self.get_body_params().get('RecognizeType')

	def set_RecognizeType(self,RecognizeType):
		self.add_body_params('RecognizeType', RecognizeType)

	def get_Vendor(self):
		return self.get_body_params().get('Vendor')

	def set_Vendor(self,Vendor):
		self.add_body_params('Vendor', Vendor)

	def get_ImageUrl(self):
		return self.get_body_params().get('ImageUrl')

	def set_ImageUrl(self,ImageUrl):
		self.add_body_params('ImageUrl', ImageUrl)

	def get_ImageContent(self):
		return self.get_body_params().get('ImageContent')

	def set_ImageContent(self,ImageContent):
		self.add_body_params('ImageContent', ImageContent)