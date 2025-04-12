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
from aliyunsdkdts.endpoint import endpoint_data

class DescribeMigrationJobDetailRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Dts', '2020-01-01', 'DescribeMigrationJobDetail','dts')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_ClientToken(self): # String
		return self.get_query_params().get('ClientToken')

	def set_ClientToken(self, ClientToken):  # String
		self.add_query_param('ClientToken', ClientToken)
	def get_MigrationModeDataInitialization(self): # Boolean
		return self.get_query_params().get('MigrationMode.DataInitialization')

	def set_MigrationModeDataInitialization(self, MigrationModeDataInitialization):  # Boolean
		self.add_query_param('MigrationMode.DataInitialization', MigrationModeDataInitialization)
	def get_MigrationJobId(self): # String
		return self.get_query_params().get('MigrationJobId')

	def set_MigrationJobId(self, MigrationJobId):  # String
		self.add_query_param('MigrationJobId', MigrationJobId)
	def get_PageNum(self): # Integer
		return self.get_query_params().get('PageNum')

	def set_PageNum(self, PageNum):  # Integer
		self.add_query_param('PageNum', PageNum)
	def get_AccountId(self): # String
		return self.get_query_params().get('AccountId')

	def set_AccountId(self, AccountId):  # String
		self.add_query_param('AccountId', AccountId)
	def get_MigrationModeDataSynchronization(self): # Boolean
		return self.get_query_params().get('MigrationMode.DataSynchronization')

	def set_MigrationModeDataSynchronization(self, MigrationModeDataSynchronization):  # Boolean
		self.add_query_param('MigrationMode.DataSynchronization', MigrationModeDataSynchronization)
	def get_PageSize(self): # Integer
		return self.get_query_params().get('PageSize')

	def set_PageSize(self, PageSize):  # Integer
		self.add_query_param('PageSize', PageSize)
	def get_OwnerId(self): # String
		return self.get_query_params().get('OwnerId')

	def set_OwnerId(self, OwnerId):  # String
		self.add_query_param('OwnerId', OwnerId)
	def get_MigrationModeStructureInitialization(self): # Boolean
		return self.get_query_params().get('MigrationMode.StructureInitialization')

	def set_MigrationModeStructureInitialization(self, MigrationModeStructureInitialization):  # Boolean
		self.add_query_param('MigrationMode.StructureInitialization', MigrationModeStructureInitialization)
