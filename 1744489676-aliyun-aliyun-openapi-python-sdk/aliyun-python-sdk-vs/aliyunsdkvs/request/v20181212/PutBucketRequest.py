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
from aliyunsdkvs.endpoint import endpoint_data

class PutBucketRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'vs', '2018-12-12', 'PutBucket')
		self.set_method('POST')
		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())


	def get_DataRedundancyType(self):
		return self.get_query_params().get('DataRedundancyType')

	def set_DataRedundancyType(self,DataRedundancyType):
		self.add_query_param('DataRedundancyType',DataRedundancyType)

	def get_Endpoint(self):
		return self.get_query_params().get('Endpoint')

	def set_Endpoint(self,Endpoint):
		self.add_query_param('Endpoint',Endpoint)

	def get_BucketName(self):
		return self.get_query_params().get('BucketName')

	def set_BucketName(self,BucketName):
		self.add_query_param('BucketName',BucketName)

	def get_BucketAcl(self):
		return self.get_query_params().get('BucketAcl')

	def set_BucketAcl(self,BucketAcl):
		self.add_query_param('BucketAcl',BucketAcl)

	def get_DispatcherType(self):
		return self.get_query_params().get('DispatcherType')

	def set_DispatcherType(self,DispatcherType):
		self.add_query_param('DispatcherType',DispatcherType)

	def get_OwnerId(self):
		return self.get_query_params().get('OwnerId')

	def set_OwnerId(self,OwnerId):
		self.add_query_param('OwnerId',OwnerId)

	def get_ResourceType(self):
		return self.get_query_params().get('ResourceType')

	def set_ResourceType(self,ResourceType):
		self.add_query_param('ResourceType',ResourceType)

	def get_StorageClass(self):
		return self.get_query_params().get('StorageClass')

	def set_StorageClass(self,StorageClass):
		self.add_query_param('StorageClass',StorageClass)

	def get_Comment(self):
		return self.get_query_params().get('Comment')

	def set_Comment(self,Comment):
		self.add_query_param('Comment',Comment)