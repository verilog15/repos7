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

class ListCorpMetricsStatisticRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'CDRS', '2020-11-01', 'ListCorpMetricsStatistic')
		self.set_method('POST')

	def get_CorpId(self):
		return self.get_body_params().get('CorpId')

	def set_CorpId(self,CorpId):
		self.add_body_params('CorpId', CorpId)

	def get_EndTime(self):
		return self.get_body_params().get('EndTime')

	def set_EndTime(self,EndTime):
		self.add_body_params('EndTime', EndTime)

	def get_StartTime(self):
		return self.get_body_params().get('StartTime')

	def set_StartTime(self,StartTime):
		self.add_body_params('StartTime', StartTime)

	def get_PageNumber(self):
		return self.get_body_params().get('PageNumber')

	def set_PageNumber(self,PageNumber):
		self.add_body_params('PageNumber', PageNumber)

	def get_DeviceGroupList(self):
		return self.get_body_params().get('DeviceGroupList')

	def set_DeviceGroupList(self,DeviceGroupList):
		self.add_body_params('DeviceGroupList', DeviceGroupList)

	def get_TagCode(self):
		return self.get_body_params().get('TagCode')

	def set_TagCode(self,TagCode):
		self.add_body_params('TagCode', TagCode)

	def get_UserGroupList(self):
		return self.get_body_params().get('UserGroupList')

	def set_UserGroupList(self,UserGroupList):
		self.add_body_params('UserGroupList', UserGroupList)

	def get_PageSize(self):
		return self.get_body_params().get('PageSize')

	def set_PageSize(self,PageSize):
		self.add_body_params('PageSize', PageSize)

	def get_DeviceIdList(self):
		return self.get_body_params().get('DeviceIdList')

	def set_DeviceIdList(self,DeviceIdList):
		self.add_body_params('DeviceIdList', DeviceIdList)