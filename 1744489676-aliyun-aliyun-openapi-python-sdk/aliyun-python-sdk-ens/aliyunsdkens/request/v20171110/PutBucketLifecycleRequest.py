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

class PutBucketLifecycleRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Ens', '2017-11-10', 'PutBucketLifecycle','ens')
		self.set_method('POST')

	def get_Prefix(self): # String
		return self.get_query_params().get('Prefix')

	def set_Prefix(self, Prefix):  # String
		self.add_query_param('Prefix', Prefix)
	def get_AllowSameActionOverlap(self): # String
		return self.get_query_params().get('AllowSameActionOverlap')

	def set_AllowSameActionOverlap(self, AllowSameActionOverlap):  # String
		self.add_query_param('AllowSameActionOverlap', AllowSameActionOverlap)
	def get_ExpirationDays(self): # Long
		return self.get_query_params().get('ExpirationDays')

	def set_ExpirationDays(self, ExpirationDays):  # Long
		self.add_query_param('ExpirationDays', ExpirationDays)
	def get_RuleId(self): # String
		return self.get_query_params().get('RuleId')

	def set_RuleId(self, RuleId):  # String
		self.add_query_param('RuleId', RuleId)
	def get_Status(self): # String
		return self.get_query_params().get('Status')

	def set_Status(self, Status):  # String
		self.add_query_param('Status', Status)
	def get_BucketName(self): # String
		return self.get_query_params().get('BucketName')

	def set_BucketName(self, BucketName):  # String
		self.add_query_param('BucketName', BucketName)
	def get_CreatedBeforeDate(self): # String
		return self.get_query_params().get('CreatedBeforeDate')

	def set_CreatedBeforeDate(self, CreatedBeforeDate):  # String
		self.add_query_param('CreatedBeforeDate', CreatedBeforeDate)
