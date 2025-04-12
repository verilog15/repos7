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
from aliyunsdkemr.endpoint import endpoint_data

class ReleaseClusterHostGroupRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Emr', '2016-04-08', 'ReleaseClusterHostGroup')
		self.set_method('POST')
		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())


	def get_ResourceOwnerId(self):
		return self.get_query_params().get('ResourceOwnerId')

	def set_ResourceOwnerId(self,ResourceOwnerId):
		self.add_query_param('ResourceOwnerId',ResourceOwnerId)

	def get_EnableGracefulDecommission(self):
		return self.get_query_params().get('EnableGracefulDecommission')

	def set_EnableGracefulDecommission(self,EnableGracefulDecommission):
		self.add_query_param('EnableGracefulDecommission',EnableGracefulDecommission)

	def get_ClusterId(self):
		return self.get_query_params().get('ClusterId')

	def set_ClusterId(self,ClusterId):
		self.add_query_param('ClusterId',ClusterId)

	def get_HostGroupId(self):
		return self.get_query_params().get('HostGroupId')

	def set_HostGroupId(self,HostGroupId):
		self.add_query_param('HostGroupId',HostGroupId)

	def get_InstanceIdList(self):
		return self.get_query_params().get('InstanceIdList')

	def set_InstanceIdList(self,InstanceIdList):
		self.add_query_param('InstanceIdList',InstanceIdList)

	def get_ReleaseNumber(self):
		return self.get_query_params().get('ReleaseNumber')

	def set_ReleaseNumber(self,ReleaseNumber):
		self.add_query_param('ReleaseNumber',ReleaseNumber)

	def get_DecommissionTimeout(self):
		return self.get_query_params().get('DecommissionTimeout')

	def set_DecommissionTimeout(self,DecommissionTimeout):
		self.add_query_param('DecommissionTimeout',DecommissionTimeout)