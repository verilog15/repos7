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

class SubmitEvaluationTaskRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'EduInterpreting', '2024-08-28', 'SubmitEvaluationTask')
		self.set_protocol_type('https')
		self.set_method('POST')

	def get_MaterialText(self): # String
		return self.get_body_params().get('MaterialText')

	def set_MaterialText(self, MaterialText):  # String
		self.add_body_params('MaterialText', MaterialText)
	def get_SuggestedAnswer(self): # String
		return self.get_body_params().get('SuggestedAnswer')

	def set_SuggestedAnswer(self, SuggestedAnswer):  # String
		self.add_body_params('SuggestedAnswer', SuggestedAnswer)
	def get_OuterBizId(self): # String
		return self.get_body_params().get('OuterBizId')

	def set_OuterBizId(self, OuterBizId):  # String
		self.add_body_params('OuterBizId', OuterBizId)
	def get_Type(self): # String
		return self.get_body_params().get('Type')

	def set_Type(self, Type):  # String
		self.add_body_params('Type', Type)
	def get_AudioUrl(self): # String
		return self.get_body_params().get('AudioUrl')

	def set_AudioUrl(self, AudioUrl):  # String
		self.add_body_params('AudioUrl', AudioUrl)
	def get_Text(self): # String
		return self.get_body_params().get('Text')

	def set_Text(self, Text):  # String
		self.add_body_params('Text', Text)
	def get_CallbackUrl(self): # String
		return self.get_body_params().get('CallbackUrl')

	def set_CallbackUrl(self, CallbackUrl):  # String
		self.add_body_params('CallbackUrl', CallbackUrl)
