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
from aliyunsdkopenanalytics_open.endpoint import endpoint_data

class UpgradeInstanceRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'openanalytics-open', '2018-06-19', 'UpgradeInstance','openanalytics')
		self.set_method('POST')
		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())


	def get_InstanceId(self):
		return self.get_body_params().get('InstanceId')

	def set_InstanceId(self,InstanceId):
		self.add_body_params('InstanceId', InstanceId)

	def get_ChargeType(self):
		return self.get_body_params().get('ChargeType')

	def set_ChargeType(self,ChargeType):
		self.add_body_params('ChargeType', ChargeType)

	def get_InstanceType(self):
		return self.get_body_params().get('InstanceType')

	def set_InstanceType(self,InstanceType):
		self.add_body_params('InstanceType', InstanceType)

	def get_Component(self):
		return self.get_body_params().get('Component')

	def set_Component(self,Component):
		self.add_body_params('Component', Component)