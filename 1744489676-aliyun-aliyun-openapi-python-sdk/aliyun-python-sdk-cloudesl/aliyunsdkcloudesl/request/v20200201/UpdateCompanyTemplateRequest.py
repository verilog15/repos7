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
from aliyunsdkcloudesl.endpoint import endpoint_data

class UpdateCompanyTemplateRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'cloudesl', '2020-02-01', 'UpdateCompanyTemplate')
		self.set_method('POST')
		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())


	def get_ExtraParams(self):
		return self.get_body_params().get('ExtraParams')

	def set_ExtraParams(self,ExtraParams):
		self.add_body_params('ExtraParams', ExtraParams)

	def get_Scene(self):
		return self.get_body_params().get('Scene')

	def set_Scene(self,Scene):
		self.add_body_params('Scene', Scene)

	def get_TemplateVersion(self):
		return self.get_body_params().get('TemplateVersion')

	def set_TemplateVersion(self,TemplateVersion):
		self.add_body_params('TemplateVersion', TemplateVersion)

	def get_TemplateName(self):
		return self.get_body_params().get('TemplateName')

	def set_TemplateName(self,TemplateName):
		self.add_body_params('TemplateName', TemplateName)

	def get_TemplateId(self):
		return self.get_body_params().get('TemplateId')

	def set_TemplateId(self,TemplateId):
		self.add_body_params('TemplateId', TemplateId)