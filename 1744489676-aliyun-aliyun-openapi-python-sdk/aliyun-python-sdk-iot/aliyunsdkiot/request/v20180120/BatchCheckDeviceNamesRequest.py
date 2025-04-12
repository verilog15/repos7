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
from aliyunsdkiot.endpoint import endpoint_data

class BatchCheckDeviceNamesRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Iot', '2018-01-20', 'BatchCheckDeviceNames','iot')
		self.set_method('POST')
		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())


	def get_DeviceNameLists(self):
		return self.get_body_params().get('DeviceNameList')

	def set_DeviceNameLists(self, DeviceNameLists):
		for depth1 in range(len(DeviceNameLists)):
			if DeviceNameLists[depth1].get('DeviceNickname') is not None:
				self.add_body_params('DeviceNameList.' + str(depth1 + 1) + '.DeviceNickname', DeviceNameLists[depth1].get('DeviceNickname'))
			if DeviceNameLists[depth1].get('DeviceName') is not None:
				self.add_body_params('DeviceNameList.' + str(depth1 + 1) + '.DeviceName', DeviceNameLists[depth1].get('DeviceName'))

	def get_IotInstanceId(self):
		return self.get_query_params().get('IotInstanceId')

	def set_IotInstanceId(self,IotInstanceId):
		self.add_query_param('IotInstanceId',IotInstanceId)

	def get_ProductKey(self):
		return self.get_query_params().get('ProductKey')

	def set_ProductKey(self,ProductKey):
		self.add_query_param('ProductKey',ProductKey)

	def get_DeviceNames(self):
		return self.get_body_params().get('DeviceName')

	def set_DeviceNames(self, DeviceNames):
		for depth1 in range(len(DeviceNames)):
			if DeviceNames[depth1] is not None:
				self.add_body_params('DeviceName.' + str(depth1 + 1) , DeviceNames[depth1])