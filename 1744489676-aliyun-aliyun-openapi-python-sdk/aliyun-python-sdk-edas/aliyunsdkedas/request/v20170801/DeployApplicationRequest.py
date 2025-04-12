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

from aliyunsdkcore.request import RoaRequest
from aliyunsdkedas.endpoint import endpoint_data

class DeployApplicationRequest(RoaRequest):

	def __init__(self):
		RoaRequest.__init__(self, 'Edas', '2017-08-01', 'DeployApplication','Edas')
		self.set_uri_pattern('/pop/v5/changeorder/co_deploy')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_BuildPackId(self): # Long
		return self.get_query_params().get('BuildPackId')

	def set_BuildPackId(self, BuildPackId):  # Long
		self.add_query_param('BuildPackId', BuildPackId)
	def get_ComponentIds(self): # String
		return self.get_query_params().get('ComponentIds')

	def set_ComponentIds(self, ComponentIds):  # String
		self.add_query_param('ComponentIds', ComponentIds)
	def get_GroupId(self): # String
		return self.get_query_params().get('GroupId')

	def set_GroupId(self, GroupId):  # String
		self.add_query_param('GroupId', GroupId)
	def get_BatchWaitTime(self): # Integer
		return self.get_query_params().get('BatchWaitTime')

	def set_BatchWaitTime(self, BatchWaitTime):  # Integer
		self.add_query_param('BatchWaitTime', BatchWaitTime)
	def get_ReleaseType(self): # Long
		return self.get_query_params().get('ReleaseType')

	def set_ReleaseType(self, ReleaseType):  # Long
		self.add_query_param('ReleaseType', ReleaseType)
	def get_Batch(self): # Integer
		return self.get_query_params().get('Batch')

	def set_Batch(self, Batch):  # Integer
		self.add_query_param('Batch', Batch)
	def get_AppEnv(self): # String
		return self.get_query_params().get('AppEnv')

	def set_AppEnv(self, AppEnv):  # String
		self.add_query_param('AppEnv', AppEnv)
	def get_PackageVersion(self): # String
		return self.get_query_params().get('PackageVersion')

	def set_PackageVersion(self, PackageVersion):  # String
		self.add_query_param('PackageVersion', PackageVersion)
	def get_Gray(self): # Boolean
		return self.get_query_params().get('Gray')

	def set_Gray(self, Gray):  # Boolean
		self.add_query_param('Gray', Gray)
	def get_AppId(self): # String
		return self.get_query_params().get('AppId')

	def set_AppId(self, AppId):  # String
		self.add_query_param('AppId', AppId)
	def get_ImageUrl(self): # String
		return self.get_query_params().get('ImageUrl')

	def set_ImageUrl(self, ImageUrl):  # String
		self.add_query_param('ImageUrl', ImageUrl)
	def get_WarUrl(self): # String
		return self.get_query_params().get('WarUrl')

	def set_WarUrl(self, WarUrl):  # String
		self.add_query_param('WarUrl', WarUrl)
	def get_TrafficControlStrategy(self): # String
		return self.get_query_params().get('TrafficControlStrategy')

	def set_TrafficControlStrategy(self, TrafficControlStrategy):  # String
		self.add_query_param('TrafficControlStrategy', TrafficControlStrategy)
	def get_Desc(self): # String
		return self.get_query_params().get('Desc')

	def set_Desc(self, Desc):  # String
		self.add_query_param('Desc', Desc)
	def get_DeployType(self): # String
		return self.get_query_params().get('DeployType')

	def set_DeployType(self, DeployType):  # String
		self.add_query_param('DeployType', DeployType)
