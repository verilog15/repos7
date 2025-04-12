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
from aliyunsdkactiontrail.endpoint import endpoint_data

class UpdateTrailRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Actiontrail', '2020-07-06', 'UpdateTrail')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_SlsProjectArn(self): # String
		return self.get_query_params().get('SlsProjectArn')

	def set_SlsProjectArn(self, SlsProjectArn):  # String
		self.add_query_param('SlsProjectArn', SlsProjectArn)
	def get_SlsWriteRoleArn(self): # String
		return self.get_query_params().get('SlsWriteRoleArn')

	def set_SlsWriteRoleArn(self, SlsWriteRoleArn):  # String
		self.add_query_param('SlsWriteRoleArn', SlsWriteRoleArn)
	def get_OssKeyPrefix(self): # String
		return self.get_query_params().get('OssKeyPrefix')

	def set_OssKeyPrefix(self, OssKeyPrefix):  # String
		self.add_query_param('OssKeyPrefix', OssKeyPrefix)
	def get_OssWriteRoleArn(self): # String
		return self.get_query_params().get('OssWriteRoleArn')

	def set_OssWriteRoleArn(self, OssWriteRoleArn):  # String
		self.add_query_param('OssWriteRoleArn', OssWriteRoleArn)
	def get_EventRW(self): # String
		return self.get_query_params().get('EventRW')

	def set_EventRW(self, EventRW):  # String
		self.add_query_param('EventRW', EventRW)
	def get_Name(self): # String
		return self.get_query_params().get('Name')

	def set_Name(self, Name):  # String
		self.add_query_param('Name', Name)
	def get_OssBucketName(self): # String
		return self.get_query_params().get('OssBucketName')

	def set_OssBucketName(self, OssBucketName):  # String
		self.add_query_param('OssBucketName', OssBucketName)
	def get_TrailRegion(self): # String
		return self.get_query_params().get('TrailRegion')

	def set_TrailRegion(self, TrailRegion):  # String
		self.add_query_param('TrailRegion', TrailRegion)
