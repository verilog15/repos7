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
from aliyunsdkimageprocess.endpoint import endpoint_data

class RunCTRegistrationRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'imageprocess', '2020-03-20', 'RunCTRegistration','imageprocess')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_DataSourceType(self): # String
		return self.get_body_params().get('DataSourceType')

	def set_DataSourceType(self, DataSourceType):  # String
		self.add_body_params('DataSourceType', DataSourceType)
	def get_OrgName(self): # String
		return self.get_body_params().get('OrgName')

	def set_OrgName(self, OrgName):  # String
		self.add_body_params('OrgName', OrgName)
	def get_ReferenceLists(self): # RepeatList
		return self.get_body_params().get('ReferenceList')

	def set_ReferenceLists(self, ReferenceList):  # RepeatList
		for depth1 in range(len(ReferenceList)):
			if ReferenceList[depth1].get('ReferenceURL') is not None:
				self.add_body_params('ReferenceList.' + str(depth1 + 1) + '.ReferenceURL', ReferenceList[depth1].get('ReferenceURL'))
	def get_DataFormat(self): # String
		return self.get_body_params().get('DataFormat')

	def set_DataFormat(self, DataFormat):  # String
		self.add_body_params('DataFormat', DataFormat)
	def get_OrgId(self): # String
		return self.get_body_params().get('OrgId')

	def set_OrgId(self, OrgId):  # String
		self.add_body_params('OrgId', OrgId)
	def get_FloatingLists(self): # RepeatList
		return self.get_body_params().get('FloatingList')

	def set_FloatingLists(self, FloatingList):  # RepeatList
		for depth1 in range(len(FloatingList)):
			if FloatingList[depth1].get('FloatingURL') is not None:
				self.add_body_params('FloatingList.' + str(depth1 + 1) + '.FloatingURL', FloatingList[depth1].get('FloatingURL'))
