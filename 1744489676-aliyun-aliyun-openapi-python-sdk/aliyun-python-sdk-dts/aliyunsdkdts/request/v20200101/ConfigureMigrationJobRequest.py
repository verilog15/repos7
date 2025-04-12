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

class ConfigureMigrationJobRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Dts', '2020-01-01', 'ConfigureMigrationJob','dts')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_SourceEndpointInstanceID(self): # String
		return self.get_query_params().get('SourceEndpoint.InstanceID')

	def set_SourceEndpointInstanceID(self, SourceEndpointInstanceID):  # String
		self.add_query_param('SourceEndpoint.InstanceID', SourceEndpointInstanceID)
	def get_Checkpoint(self): # String
		return self.get_query_params().get('Checkpoint')

	def set_Checkpoint(self, Checkpoint):  # String
		self.add_query_param('Checkpoint', Checkpoint)
	def get_DestinationEndpointInstanceID(self): # String
		return self.get_query_params().get('DestinationEndpoint.InstanceID')

	def set_DestinationEndpointInstanceID(self, DestinationEndpointInstanceID):  # String
		self.add_query_param('DestinationEndpoint.InstanceID', DestinationEndpointInstanceID)
	def get_SourceEndpointIP(self): # String
		return self.get_query_params().get('SourceEndpoint.IP')

	def set_SourceEndpointIP(self, SourceEndpointIP):  # String
		self.add_query_param('SourceEndpoint.IP', SourceEndpointIP)
	def get_DestinationEndpointPassword(self): # String
		return self.get_query_params().get('DestinationEndpoint.Password')

	def set_DestinationEndpointPassword(self, DestinationEndpointPassword):  # String
		self.add_query_param('DestinationEndpoint.Password', DestinationEndpointPassword)
	def get_MigrationModeDataIntialization(self): # Boolean
		return self.get_query_params().get('MigrationMode.DataIntialization')

	def set_MigrationModeDataIntialization(self, MigrationModeDataIntialization):  # Boolean
		self.add_query_param('MigrationMode.DataIntialization', MigrationModeDataIntialization)
	def get_AccountId(self): # String
		return self.get_query_params().get('AccountId')

	def set_AccountId(self, AccountId):  # String
		self.add_query_param('AccountId', AccountId)
	def get_MigrationModeStructureIntialization(self): # Boolean
		return self.get_query_params().get('MigrationMode.StructureIntialization')

	def set_MigrationModeStructureIntialization(self, MigrationModeStructureIntialization):  # Boolean
		self.add_query_param('MigrationMode.StructureIntialization', MigrationModeStructureIntialization)
	def get_MigrationModeDataSynchronization(self): # Boolean
		return self.get_query_params().get('MigrationMode.DataSynchronization')

	def set_MigrationModeDataSynchronization(self, MigrationModeDataSynchronization):  # Boolean
		self.add_query_param('MigrationMode.DataSynchronization', MigrationModeDataSynchronization)
	def get_DestinationEndpointRegion(self): # String
		return self.get_query_params().get('DestinationEndpoint.Region')

	def set_DestinationEndpointRegion(self, DestinationEndpointRegion):  # String
		self.add_query_param('DestinationEndpoint.Region', DestinationEndpointRegion)
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
	def get_DestinationEndpointPort(self): # String
		return self.get_query_params().get('DestinationEndpoint.Port')

	def set_DestinationEndpointPort(self, DestinationEndpointPort):  # String
		self.add_query_param('DestinationEndpoint.Port', DestinationEndpointPort)
	def get_SourceEndpointRole(self): # String
		return self.get_query_params().get('SourceEndpoint.Role')

	def set_SourceEndpointRole(self, SourceEndpointRole):  # String
		self.add_query_param('SourceEndpoint.Role', SourceEndpointRole)
	def get_OwnerId(self): # String
		return self.get_query_params().get('OwnerId')

	def set_OwnerId(self, OwnerId):  # String
		self.add_query_param('OwnerId', OwnerId)
	def get_SourceEndpointPassword(self): # String
		return self.get_query_params().get('SourceEndpoint.Password')

	def set_SourceEndpointPassword(self, SourceEndpointPassword):  # String
		self.add_query_param('SourceEndpoint.Password', SourceEndpointPassword)
	def get_DestinationEndpointIP(self): # String
		return self.get_query_params().get('DestinationEndpoint.IP')

	def set_DestinationEndpointIP(self, DestinationEndpointIP):  # String
		self.add_query_param('DestinationEndpoint.IP', DestinationEndpointIP)
	def get_MigrationJobName(self): # String
		return self.get_query_params().get('MigrationJobName')

	def set_MigrationJobName(self, MigrationJobName):  # String
		self.add_query_param('MigrationJobName', MigrationJobName)
	def get_DestinationEndpointInstanceType(self): # String
		return self.get_query_params().get('DestinationEndpoint.InstanceType')

	def set_DestinationEndpointInstanceType(self, DestinationEndpointInstanceType):  # String
		self.add_query_param('DestinationEndpoint.InstanceType', DestinationEndpointInstanceType)
	def get_SourceEndpointEngineName(self): # String
		return self.get_query_params().get('SourceEndpoint.EngineName')

	def set_SourceEndpointEngineName(self, SourceEndpointEngineName):  # String
		self.add_query_param('SourceEndpoint.EngineName', SourceEndpointEngineName)
	def get_SourceEndpointOracleSID(self): # String
		return self.get_query_params().get('SourceEndpoint.OracleSID')

	def set_SourceEndpointOracleSID(self, SourceEndpointOracleSID):  # String
		self.add_query_param('SourceEndpoint.OracleSID', SourceEndpointOracleSID)
	def get_MigrationObject(self): # String
		return self.get_body_params().get('MigrationObject')

	def set_MigrationObject(self, MigrationObject):  # String
		self.add_body_params('MigrationObject', MigrationObject)
	def get_MigrationJobId(self): # String
		return self.get_query_params().get('MigrationJobId')

	def set_MigrationJobId(self, MigrationJobId):  # String
		self.add_query_param('MigrationJobId', MigrationJobId)
	def get_SourceEndpointInstanceType(self): # String
		return self.get_query_params().get('SourceEndpoint.InstanceType')

	def set_SourceEndpointInstanceType(self, SourceEndpointInstanceType):  # String
		self.add_query_param('SourceEndpoint.InstanceType', SourceEndpointInstanceType)
	def get_DestinationEndpointEngineName(self): # String
		return self.get_query_params().get('DestinationEndpoint.EngineName')

	def set_DestinationEndpointEngineName(self, DestinationEndpointEngineName):  # String
		self.add_query_param('DestinationEndpoint.EngineName', DestinationEndpointEngineName)
	def get_DestinationEndpointUserName(self): # String
		return self.get_query_params().get('DestinationEndpoint.UserName')

	def set_DestinationEndpointUserName(self, DestinationEndpointUserName):  # String
		self.add_query_param('DestinationEndpoint.UserName', DestinationEndpointUserName)
	def get_DestinationEndpointOracleSID(self): # String
		return self.get_query_params().get('DestinationEndpoint.OracleSID')

	def set_DestinationEndpointOracleSID(self, DestinationEndpointOracleSID):  # String
		self.add_query_param('DestinationEndpoint.OracleSID', DestinationEndpointOracleSID)
	def get_SourceEndpointRegion(self): # String
		return self.get_query_params().get('SourceEndpoint.Region')

	def set_SourceEndpointRegion(self, SourceEndpointRegion):  # String
		self.add_query_param('SourceEndpoint.Region', SourceEndpointRegion)
	def get_DestinationEndpointDataBaseName(self): # String
		return self.get_query_params().get('DestinationEndpoint.DataBaseName')

	def set_DestinationEndpointDataBaseName(self, DestinationEndpointDataBaseName):  # String
		self.add_query_param('DestinationEndpoint.DataBaseName', DestinationEndpointDataBaseName)
	def get_MigrationReserved(self): # String
		return self.get_query_params().get('MigrationReserved')

	def set_MigrationReserved(self, MigrationReserved):  # String
		self.add_query_param('MigrationReserved', MigrationReserved)
