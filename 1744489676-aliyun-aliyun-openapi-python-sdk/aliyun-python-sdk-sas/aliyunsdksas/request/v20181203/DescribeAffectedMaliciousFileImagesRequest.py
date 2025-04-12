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
from aliyunsdksas.endpoint import endpoint_data

class DescribeAffectedMaliciousFileImagesRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Sas', '2018-12-03', 'DescribeAffectedMaliciousFileImages','sas')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_RepoId(self): # String
		return self.get_query_params().get('RepoId')

	def set_RepoId(self, RepoId):  # String
		self.add_query_param('RepoId', RepoId)
	def get_Pod(self): # String
		return self.get_query_params().get('Pod')

	def set_Pod(self, Pod):  # String
		self.add_query_param('Pod', Pod)
	def get_ClusterName(self): # String
		return self.get_query_params().get('ClusterName')

	def set_ClusterName(self, ClusterName):  # String
		self.add_query_param('ClusterName', ClusterName)
	def get_RepoNamespace(self): # String
		return self.get_query_params().get('RepoNamespace')

	def set_RepoNamespace(self, RepoNamespace):  # String
		self.add_query_param('RepoNamespace', RepoNamespace)
	def get_ImageDigest(self): # String
		return self.get_query_params().get('ImageDigest')

	def set_ImageDigest(self, ImageDigest):  # String
		self.add_query_param('ImageDigest', ImageDigest)
	def get_ScanRanges(self): # RepeatList
		return self.get_query_params().get('ScanRange')

	def set_ScanRanges(self, ScanRange):  # RepeatList
		for depth1 in range(len(ScanRange)):
			self.add_query_param('ScanRange.' + str(depth1 + 1), ScanRange[depth1])
	def get_PageSize(self): # String
		return self.get_query_params().get('PageSize')

	def set_PageSize(self, PageSize):  # String
		self.add_query_param('PageSize', PageSize)
	def get_Lang(self): # String
		return self.get_query_params().get('Lang')

	def set_Lang(self, Lang):  # String
		self.add_query_param('Lang', Lang)
	def get_ImageTag(self): # String
		return self.get_query_params().get('ImageTag')

	def set_ImageTag(self, ImageTag):  # String
		self.add_query_param('ImageTag', ImageTag)
	def get_Image(self): # String
		return self.get_query_params().get('Image')

	def set_Image(self, Image):  # String
		self.add_query_param('Image', Image)
	def get_MaliciousMd5(self): # String
		return self.get_query_params().get('MaliciousMd5')

	def set_MaliciousMd5(self, MaliciousMd5):  # String
		self.add_query_param('MaliciousMd5', MaliciousMd5)
	def get_CurrentPage(self): # Integer
		return self.get_query_params().get('CurrentPage')

	def set_CurrentPage(self, CurrentPage):  # Integer
		self.add_query_param('CurrentPage', CurrentPage)
	def get_ClusterId(self): # String
		return self.get_query_params().get('ClusterId')

	def set_ClusterId(self, ClusterId):  # String
		self.add_query_param('ClusterId', ClusterId)
	def get_RepoName(self): # String
		return self.get_query_params().get('RepoName')

	def set_RepoName(self, RepoName):  # String
		self.add_query_param('RepoName', RepoName)
	def get_Namespace(self): # String
		return self.get_query_params().get('Namespace')

	def set_Namespace(self, Namespace):  # String
		self.add_query_param('Namespace', Namespace)
	def get_RepoInstanceId(self): # String
		return self.get_query_params().get('RepoInstanceId')

	def set_RepoInstanceId(self, RepoInstanceId):  # String
		self.add_query_param('RepoInstanceId', RepoInstanceId)
	def get_ImageLayer(self): # String
		return self.get_query_params().get('ImageLayer')

	def set_ImageLayer(self, ImageLayer):  # String
		self.add_query_param('ImageLayer', ImageLayer)
	def get_ContainerId(self): # String
		return self.get_query_params().get('ContainerId')

	def set_ContainerId(self, ContainerId):  # String
		self.add_query_param('ContainerId', ContainerId)
	def get_Levels(self): # String
		return self.get_query_params().get('Levels')

	def set_Levels(self, Levels):  # String
		self.add_query_param('Levels', Levels)
	def get_RepoRegionId(self): # String
		return self.get_query_params().get('RepoRegionId')

	def set_RepoRegionId(self, RepoRegionId):  # String
		self.add_query_param('RepoRegionId', RepoRegionId)
	def get_Status(self): # String
		return self.get_query_params().get('Status')

	def set_Status(self, Status):  # String
		self.add_query_param('Status', Status)
