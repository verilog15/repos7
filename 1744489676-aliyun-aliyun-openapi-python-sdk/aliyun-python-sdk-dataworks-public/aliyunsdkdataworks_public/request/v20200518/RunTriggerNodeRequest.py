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
from aliyunsdkdataworks_public.endpoint import endpoint_data

class RunTriggerNodeRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'dataworks-public', '2020-05-18', 'RunTriggerNode')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_BizDate(self): # Long
		return self.get_body_params().get('BizDate')

	def set_BizDate(self, BizDate):  # Long
		self.add_body_params('BizDate', BizDate)
	def get_AppId(self): # Long
		return self.get_body_params().get('AppId')

	def set_AppId(self, AppId):  # Long
		self.add_body_params('AppId', AppId)
	def get_CycleTime(self): # Long
		return self.get_body_params().get('CycleTime')

	def set_CycleTime(self, CycleTime):  # Long
		self.add_body_params('CycleTime', CycleTime)
	def get_NodeId(self): # Long
		return self.get_body_params().get('NodeId')

	def set_NodeId(self, NodeId):  # Long
		self.add_body_params('NodeId', NodeId)
