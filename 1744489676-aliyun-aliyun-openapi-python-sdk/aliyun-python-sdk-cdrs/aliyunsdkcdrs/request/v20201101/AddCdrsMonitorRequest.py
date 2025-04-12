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

class AddCdrsMonitorRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'CDRS', '2020-11-01', 'AddCdrsMonitor')
		self.set_method('POST')

	def get_MonitorType(self):
		return self.get_body_params().get('MonitorType')

	def set_MonitorType(self,MonitorType):
		self.add_body_params('MonitorType', MonitorType)

	def get_CorpId(self):
		return self.get_body_params().get('CorpId')

	def set_CorpId(self,CorpId):
		self.add_body_params('CorpId', CorpId)

	def get_Description(self):
		return self.get_body_params().get('Description')

	def set_Description(self,Description):
		self.add_body_params('Description', Description)

	def get_NotifierAppSecret(self):
		return self.get_body_params().get('NotifierAppSecret')

	def set_NotifierAppSecret(self,NotifierAppSecret):
		self.add_body_params('NotifierAppSecret', NotifierAppSecret)

	def get_NotifierExtendValues(self):
		return self.get_body_params().get('NotifierExtendValues')

	def set_NotifierExtendValues(self,NotifierExtendValues):
		self.add_body_params('NotifierExtendValues', NotifierExtendValues)

	def get_NotifierUrl(self):
		return self.get_body_params().get('NotifierUrl')

	def set_NotifierUrl(self,NotifierUrl):
		self.add_body_params('NotifierUrl', NotifierUrl)

	def get_NotifierType(self):
		return self.get_body_params().get('NotifierType')

	def set_NotifierType(self,NotifierType):
		self.add_body_params('NotifierType', NotifierType)

	def get_BatchIndicator(self):
		return self.get_body_params().get('BatchIndicator')

	def set_BatchIndicator(self,BatchIndicator):
		self.add_body_params('BatchIndicator', BatchIndicator)

	def get_NotifierTimeOut(self):
		return self.get_body_params().get('NotifierTimeOut')

	def set_NotifierTimeOut(self,NotifierTimeOut):
		self.add_body_params('NotifierTimeOut', NotifierTimeOut)

	def get_AlgorithmVendor(self):
		return self.get_body_params().get('AlgorithmVendor')

	def set_AlgorithmVendor(self,AlgorithmVendor):
		self.add_body_params('AlgorithmVendor', AlgorithmVendor)