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
from aliyunsdkfacebody.endpoint import endpoint_data

class DetectLivingFaceRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'facebody', '2019-12-30', 'DetectLivingFace','facebody')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_Taskss(self): # RepeatList
		return self.get_body_params().get('Tasks')

	def set_Taskss(self, Tasks):  # RepeatList
		for depth1 in range(len(Tasks)):
			if Tasks[depth1].get('ImageURL') is not None:
				self.add_body_params('Tasks.' + str(depth1 + 1) + '.ImageURL', Tasks[depth1].get('ImageURL'))
			if Tasks[depth1].get('ImageData') is not None:
				self.add_body_params('Tasks.' + str(depth1 + 1) + '.ImageData', Tasks[depth1].get('ImageData'))
