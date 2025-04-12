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

class ConfigureSubscriptionInstanceRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Dts', '2020-01-01', 'ConfigureSubscriptionInstance','dts')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_SourceEndpointInstanceID(self): # String
		return self.get_query_params().get('SourceEndpoint.InstanceID')

	def set_SourceEndpointInstanceID(self, SourceEndpointInstanceID):  # String
		self.add_query_param('SourceEndpoint.InstanceID', SourceEndpointInstanceID)
	def get_SourceEndpointOracleSID(self): # String
		return self.get_query_params().get('SourceEndpoint.OracleSID')

	def set_SourceEndpointOracleSID(self, SourceEndpointOracleSID):  # String
		self.add_query_param('SourceEndpoint.OracleSID', SourceEndpointOracleSID)
	def get_SourceEndpointIP(self): # String
		return self.get_query_params().get('SourceEndpoint.IP')

	def set_SourceEndpointIP(self, SourceEndpointIP):  # String
		self.add_query_param('SourceEndpoint.IP', SourceEndpointIP)
	def get_SubscriptionDataTypeDML(self): # Boolean
		return self.get_query_params().get('SubscriptionDataType.DML')

	def set_SubscriptionDataTypeDML(self, SubscriptionDataTypeDML):  # Boolean
		self.add_query_param('SubscriptionDataType.DML', SubscriptionDataTypeDML)
	def get_SourceEndpointInstanceType(self): # String
		return self.get_query_params().get('SourceEndpoint.InstanceType')

	def set_SourceEndpointInstanceType(self, SourceEndpointInstanceType):  # String
		self.add_query_param('SourceEndpoint.InstanceType', SourceEndpointInstanceType)
	def get_AccountId(self): # String
		return self.get_query_params().get('AccountId')

	def set_AccountId(self, AccountId):  # String
		self.add_query_param('AccountId', AccountId)
	def get_SubscriptionObject(self): # String
		return self.get_body_params().get('SubscriptionObject')

	def set_SubscriptionObject(self, SubscriptionObject):  # String
		self.add_body_params('SubscriptionObject', SubscriptionObject)
	def get_SubscriptionInstanceVSwitchId(self): # String
		return self.get_query_params().get('SubscriptionInstance.VSwitchId')

	def set_SubscriptionInstanceVSwitchId(self, SubscriptionInstanceVSwitchId):  # String
		self.add_query_param('SubscriptionInstance.VSwitchId', SubscriptionInstanceVSwitchId)
	def get_SourceEndpointUserName(self): # String
		return self.get_query_params().get('SourceEndpoint.UserName')

	def set_SourceEndpointUserName(self, SourceEndpointUserName):  # String
		self.add_query_param('SourceEndpoint.UserName', SourceEndpointUserName)
	def get_SourceEndpointDatabaseName(self): # String
		return self.get_query_params().get('SourceEndpoint.DatabaseName')

	def set_SourceEndpointDatabaseName(self, SourceEndpointDatabaseName):  # String
		self.add_query_param('SourceEndpoint.DatabaseName', SourceEndpointDatabaseName)
	def get_SourceEndpointPort(self): # String
		return self.get_query_params().get('SourceEndpoint.Port')

	def set_SourceEndpointPort(self, SourceEndpointPort):  # String
		self.add_query_param('SourceEndpoint.Port', SourceEndpointPort)
	def get_SourceEndpointOwnerID(self): # String
		return self.get_query_params().get('SourceEndpoint.OwnerID')

	def set_SourceEndpointOwnerID(self, SourceEndpointOwnerID):  # String
		self.add_query_param('SourceEndpoint.OwnerID', SourceEndpointOwnerID)
	def get_SubscriptionInstanceVPCId(self): # String
		return self.get_query_params().get('SubscriptionInstance.VPCId')

	def set_SubscriptionInstanceVPCId(self, SubscriptionInstanceVPCId):  # String
		self.add_query_param('SubscriptionInstance.VPCId', SubscriptionInstanceVPCId)
	def get_SubscriptionInstanceNetworkType(self): # String
		return self.get_query_params().get('SubscriptionInstanceNetworkType')

	def set_SubscriptionInstanceNetworkType(self, SubscriptionInstanceNetworkType):  # String
		self.add_query_param('SubscriptionInstanceNetworkType', SubscriptionInstanceNetworkType)
	def get_SubscriptionInstanceId(self): # String
		return self.get_query_params().get('SubscriptionInstanceId')

	def set_SubscriptionInstanceId(self, SubscriptionInstanceId):  # String
		self.add_query_param('SubscriptionInstanceId', SubscriptionInstanceId)
	def get_SourceEndpointRole(self): # String
		return self.get_query_params().get('SourceEndpoint.Role')

	def set_SourceEndpointRole(self, SourceEndpointRole):  # String
		self.add_query_param('SourceEndpoint.Role', SourceEndpointRole)
	def get_OwnerId(self): # String
		return self.get_query_params().get('OwnerId')

	def set_OwnerId(self, OwnerId):  # String
		self.add_query_param('OwnerId', OwnerId)
	def get_SubscriptionDataTypeDDL(self): # Boolean
		return self.get_query_params().get('SubscriptionDataType.DDL')

	def set_SubscriptionDataTypeDDL(self, SubscriptionDataTypeDDL):  # Boolean
		self.add_query_param('SubscriptionDataType.DDL', SubscriptionDataTypeDDL)
	def get_SourceEndpointPassword(self): # String
		return self.get_query_params().get('SourceEndpoint.Password')

	def set_SourceEndpointPassword(self, SourceEndpointPassword):  # String
		self.add_query_param('SourceEndpoint.Password', SourceEndpointPassword)
	def get_SubscriptionInstanceName(self): # String
		return self.get_query_params().get('SubscriptionInstanceName')

	def set_SubscriptionInstanceName(self, SubscriptionInstanceName):  # String
		self.add_query_param('SubscriptionInstanceName', SubscriptionInstanceName)
