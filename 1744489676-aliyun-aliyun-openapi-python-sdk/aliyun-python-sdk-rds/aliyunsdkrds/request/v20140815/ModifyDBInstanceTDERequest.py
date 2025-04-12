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
from aliyunsdkrds.endpoint import endpoint_data

class ModifyDBInstanceTDERequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Rds', '2014-08-15', 'ModifyDBInstanceTDE','rds')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_ResourceOwnerId(self): # Long
		return self.get_query_params().get('ResourceOwnerId')

	def set_ResourceOwnerId(self, ResourceOwnerId):  # Long
		self.add_query_param('ResourceOwnerId', ResourceOwnerId)
	def get_Certificate(self): # String
		return self.get_query_params().get('Certificate')

	def set_Certificate(self, Certificate):  # String
		self.add_query_param('Certificate', Certificate)
	def get_PrivateKey(self): # String
		return self.get_query_params().get('PrivateKey')

	def set_PrivateKey(self, PrivateKey):  # String
		self.add_query_param('PrivateKey', PrivateKey)
	def get_PassWord(self): # String
		return self.get_query_params().get('PassWord')

	def set_PassWord(self, PassWord):  # String
		self.add_query_param('PassWord', PassWord)
	def get_DBInstanceId(self): # String
		return self.get_query_params().get('DBInstanceId')

	def set_DBInstanceId(self, DBInstanceId):  # String
		self.add_query_param('DBInstanceId', DBInstanceId)
	def get_ResourceOwnerAccount(self): # String
		return self.get_query_params().get('ResourceOwnerAccount')

	def set_ResourceOwnerAccount(self, ResourceOwnerAccount):  # String
		self.add_query_param('ResourceOwnerAccount', ResourceOwnerAccount)
	def get_OwnerAccount(self): # String
		return self.get_query_params().get('OwnerAccount')

	def set_OwnerAccount(self, OwnerAccount):  # String
		self.add_query_param('OwnerAccount', OwnerAccount)
	def get_IsRotate(self): # Boolean
		return self.get_query_params().get('IsRotate')

	def set_IsRotate(self, IsRotate):  # Boolean
		self.add_query_param('IsRotate', IsRotate)
	def get_EncryptionKey(self): # String
		return self.get_query_params().get('EncryptionKey')

	def set_EncryptionKey(self, EncryptionKey):  # String
		self.add_query_param('EncryptionKey', EncryptionKey)
	def get_OwnerId(self): # Long
		return self.get_query_params().get('OwnerId')

	def set_OwnerId(self, OwnerId):  # Long
		self.add_query_param('OwnerId', OwnerId)
	def get_DBName(self): # String
		return self.get_query_params().get('DBName')

	def set_DBName(self, DBName):  # String
		self.add_query_param('DBName', DBName)
	def get_RoleArn(self): # String
		return self.get_query_params().get('RoleArn')

	def set_RoleArn(self, RoleArn):  # String
		self.add_query_param('RoleArn', RoleArn)
	def get_TDEStatus(self): # String
		return self.get_query_params().get('TDEStatus')

	def set_TDEStatus(self, TDEStatus):  # String
		self.add_query_param('TDEStatus', TDEStatus)
