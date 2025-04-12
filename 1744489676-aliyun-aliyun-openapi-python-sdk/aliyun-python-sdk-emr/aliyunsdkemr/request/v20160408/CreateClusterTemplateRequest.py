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

class CreateClusterTemplateRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Emr', '2016-04-08', 'CreateClusterTemplate')
		self.set_method('POST')
		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())


	def get_ResourceOwnerId(self):
		return self.get_query_params().get('ResourceOwnerId')

	def set_ResourceOwnerId(self,ResourceOwnerId):
		self.add_query_param('ResourceOwnerId',ResourceOwnerId)

	def get_LogPath(self):
		return self.get_query_params().get('LogPath')

	def set_LogPath(self,LogPath):
		self.add_query_param('LogPath',LogPath)

	def get_MasterPwd(self):
		return self.get_query_params().get('MasterPwd')

	def set_MasterPwd(self,MasterPwd):
		self.add_query_param('MasterPwd',MasterPwd)

	def get_Configurations(self):
		return self.get_query_params().get('Configurations')

	def set_Configurations(self,Configurations):
		self.add_query_param('Configurations',Configurations)

	def get_SshEnable(self):
		return self.get_query_params().get('SshEnable')

	def set_SshEnable(self,SshEnable):
		self.add_query_param('SshEnable',SshEnable)

	def get_KeyPairName(self):
		return self.get_query_params().get('KeyPairName')

	def set_KeyPairName(self,KeyPairName):
		self.add_query_param('KeyPairName',KeyPairName)

	def get_MetaStoreType(self):
		return self.get_query_params().get('MetaStoreType')

	def set_MetaStoreType(self,MetaStoreType):
		self.add_query_param('MetaStoreType',MetaStoreType)

	def get_SecurityGroupName(self):
		return self.get_query_params().get('SecurityGroupName')

	def set_SecurityGroupName(self,SecurityGroupName):
		self.add_query_param('SecurityGroupName',SecurityGroupName)

	def get_MachineType(self):
		return self.get_query_params().get('MachineType')

	def set_MachineType(self,MachineType):
		self.add_query_param('MachineType',MachineType)

	def get_ResourceGroupId(self):
		return self.get_query_params().get('ResourceGroupId')

	def set_ResourceGroupId(self,ResourceGroupId):
		self.add_query_param('ResourceGroupId',ResourceGroupId)

	def get_BootstrapActions(self):
		return self.get_query_params().get('BootstrapAction')

	def set_BootstrapActions(self, BootstrapActions):
		for depth1 in range(len(BootstrapActions)):
			if BootstrapActions[depth1].get('Path') is not None:
				self.add_query_param('BootstrapAction.' + str(depth1 + 1) + '.Path', BootstrapActions[depth1].get('Path'))
			if BootstrapActions[depth1].get('ExecutionTarget') is not None:
				self.add_query_param('BootstrapAction.' + str(depth1 + 1) + '.ExecutionTarget', BootstrapActions[depth1].get('ExecutionTarget'))
			if BootstrapActions[depth1].get('ExecutionMoment') is not None:
				self.add_query_param('BootstrapAction.' + str(depth1 + 1) + '.ExecutionMoment', BootstrapActions[depth1].get('ExecutionMoment'))
			if BootstrapActions[depth1].get('Arg') is not None:
				self.add_query_param('BootstrapAction.' + str(depth1 + 1) + '.Arg', BootstrapActions[depth1].get('Arg'))
			if BootstrapActions[depth1].get('Name') is not None:
				self.add_query_param('BootstrapAction.' + str(depth1 + 1) + '.Name', BootstrapActions[depth1].get('Name'))
			if BootstrapActions[depth1].get('ExecutionFailStrategy') is not None:
				self.add_query_param('BootstrapAction.' + str(depth1 + 1) + '.ExecutionFailStrategy', BootstrapActions[depth1].get('ExecutionFailStrategy'))

	def get_MetaStoreConf(self):
		return self.get_query_params().get('MetaStoreConf')

	def set_MetaStoreConf(self,MetaStoreConf):
		self.add_query_param('MetaStoreConf',MetaStoreConf)

	def get_EmrVer(self):
		return self.get_query_params().get('EmrVer')

	def set_EmrVer(self,EmrVer):
		self.add_query_param('EmrVer',EmrVer)

	def get_Tags(self):
		return self.get_query_params().get('Tag')

	def set_Tags(self, Tags):
		for depth1 in range(len(Tags)):
			if Tags[depth1].get('Value') is not None:
				self.add_query_param('Tag.' + str(depth1 + 1) + '.Value', Tags[depth1].get('Value'))
			if Tags[depth1].get('Key') is not None:
				self.add_query_param('Tag.' + str(depth1 + 1) + '.Key', Tags[depth1].get('Key'))

	def get_IsOpenPublicIp(self):
		return self.get_query_params().get('IsOpenPublicIp')

	def set_IsOpenPublicIp(self,IsOpenPublicIp):
		self.add_query_param('IsOpenPublicIp',IsOpenPublicIp)

	def get_Period(self):
		return self.get_query_params().get('Period')

	def set_Period(self,Period):
		self.add_query_param('Period',Period)

	def get_InstanceGeneration(self):
		return self.get_query_params().get('InstanceGeneration')

	def set_InstanceGeneration(self,InstanceGeneration):
		self.add_query_param('InstanceGeneration',InstanceGeneration)

	def get_VSwitchId(self):
		return self.get_query_params().get('VSwitchId')

	def set_VSwitchId(self,VSwitchId):
		self.add_query_param('VSwitchId',VSwitchId)

	def get_ClusterType(self):
		return self.get_query_params().get('ClusterType')

	def set_ClusterType(self,ClusterType):
		self.add_query_param('ClusterType',ClusterType)

	def get_AutoRenew(self):
		return self.get_query_params().get('AutoRenew')

	def set_AutoRenew(self,AutoRenew):
		self.add_query_param('AutoRenew',AutoRenew)

	def get_OptionSoftWareLists(self):
		return self.get_query_params().get('OptionSoftWareList')

	def set_OptionSoftWareLists(self, OptionSoftWareLists):
		for depth1 in range(len(OptionSoftWareLists)):
			if OptionSoftWareLists[depth1] is not None:
				self.add_query_param('OptionSoftWareList.' + str(depth1 + 1) , OptionSoftWareLists[depth1])

	def get_NetType(self):
		return self.get_query_params().get('NetType')

	def set_NetType(self,NetType):
		self.add_query_param('NetType',NetType)

	def get_ZoneId(self):
		return self.get_query_params().get('ZoneId')

	def set_ZoneId(self,ZoneId):
		self.add_query_param('ZoneId',ZoneId)

	def get_UseCustomHiveMetaDb(self):
		return self.get_query_params().get('UseCustomHiveMetaDb')

	def set_UseCustomHiveMetaDb(self,UseCustomHiveMetaDb):
		self.add_query_param('UseCustomHiveMetaDb',UseCustomHiveMetaDb)

	def get_InitCustomHiveMetaDb(self):
		return self.get_query_params().get('InitCustomHiveMetaDb')

	def set_InitCustomHiveMetaDb(self,InitCustomHiveMetaDb):
		self.add_query_param('InitCustomHiveMetaDb',InitCustomHiveMetaDb)

	def get_ClientToken(self):
		return self.get_query_params().get('ClientToken')

	def set_ClientToken(self,ClientToken):
		self.add_query_param('ClientToken',ClientToken)

	def get_IoOptimized(self):
		return self.get_query_params().get('IoOptimized')

	def set_IoOptimized(self,IoOptimized):
		self.add_query_param('IoOptimized',IoOptimized)

	def get_SecurityGroupId(self):
		return self.get_query_params().get('SecurityGroupId')

	def set_SecurityGroupId(self,SecurityGroupId):
		self.add_query_param('SecurityGroupId',SecurityGroupId)

	def get_EasEnable(self):
		return self.get_query_params().get('EasEnable')

	def set_EasEnable(self,EasEnable):
		self.add_query_param('EasEnable',EasEnable)

	def get_DepositType(self):
		return self.get_query_params().get('DepositType')

	def set_DepositType(self,DepositType):
		self.add_query_param('DepositType',DepositType)

	def get_DataDiskKMSKeyId(self):
		return self.get_query_params().get('DataDiskKMSKeyId')

	def set_DataDiskKMSKeyId(self,DataDiskKMSKeyId):
		self.add_query_param('DataDiskKMSKeyId',DataDiskKMSKeyId)

	def get_UseLocalMetaDb(self):
		return self.get_query_params().get('UseLocalMetaDb')

	def set_UseLocalMetaDb(self,UseLocalMetaDb):
		self.add_query_param('UseLocalMetaDb',UseLocalMetaDb)

	def get_TemplateName(self):
		return self.get_query_params().get('TemplateName')

	def set_TemplateName(self,TemplateName):
		self.add_query_param('TemplateName',TemplateName)

	def get_UserDefinedEmrEcsRole(self):
		return self.get_query_params().get('UserDefinedEmrEcsRole')

	def set_UserDefinedEmrEcsRole(self,UserDefinedEmrEcsRole):
		self.add_query_param('UserDefinedEmrEcsRole',UserDefinedEmrEcsRole)

	def get_DataDiskEncrypted(self):
		return self.get_query_params().get('DataDiskEncrypted')

	def set_DataDiskEncrypted(self,DataDiskEncrypted):
		self.add_query_param('DataDiskEncrypted',DataDiskEncrypted)

	def get_VpcId(self):
		return self.get_query_params().get('VpcId')

	def set_VpcId(self,VpcId):
		self.add_query_param('VpcId',VpcId)

	def get_HostGroups(self):
		return self.get_query_params().get('HostGroup')

	def set_HostGroups(self, HostGroups):
		for depth1 in range(len(HostGroups)):
			if HostGroups[depth1].get('Period') is not None:
				self.add_query_param('HostGroup.' + str(depth1 + 1) + '.Period', HostGroups[depth1].get('Period'))
			if HostGroups[depth1].get('SysDiskCapacity') is not None:
				self.add_query_param('HostGroup.' + str(depth1 + 1) + '.SysDiskCapacity', HostGroups[depth1].get('SysDiskCapacity'))
			if HostGroups[depth1].get('PrivatePoolOptionsId') is not None:
				self.add_query_param('HostGroup.' + str(depth1 + 1) + '.PrivatePoolOptionsId', HostGroups[depth1].get('PrivatePoolOptionsId'))
			if HostGroups[depth1].get('DiskCapacity') is not None:
				self.add_query_param('HostGroup.' + str(depth1 + 1) + '.DiskCapacity', HostGroups[depth1].get('DiskCapacity'))
			if HostGroups[depth1].get('SysDiskType') is not None:
				self.add_query_param('HostGroup.' + str(depth1 + 1) + '.SysDiskType', HostGroups[depth1].get('SysDiskType'))
			if HostGroups[depth1].get('ClusterId') is not None:
				self.add_query_param('HostGroup.' + str(depth1 + 1) + '.ClusterId', HostGroups[depth1].get('ClusterId'))
			if HostGroups[depth1].get('DiskType') is not None:
				self.add_query_param('HostGroup.' + str(depth1 + 1) + '.DiskType', HostGroups[depth1].get('DiskType'))
			if HostGroups[depth1].get('HostGroupName') is not None:
				self.add_query_param('HostGroup.' + str(depth1 + 1) + '.HostGroupName', HostGroups[depth1].get('HostGroupName'))
			if HostGroups[depth1].get('VSwitchId') is not None:
				self.add_query_param('HostGroup.' + str(depth1 + 1) + '.VSwitchId', HostGroups[depth1].get('VSwitchId'))
			if HostGroups[depth1].get('DiskCount') is not None:
				self.add_query_param('HostGroup.' + str(depth1 + 1) + '.DiskCount', HostGroups[depth1].get('DiskCount'))
			if HostGroups[depth1].get('AutoRenew') is not None:
				self.add_query_param('HostGroup.' + str(depth1 + 1) + '.AutoRenew', HostGroups[depth1].get('AutoRenew'))
			if HostGroups[depth1].get('HostGroupId') is not None:
				self.add_query_param('HostGroup.' + str(depth1 + 1) + '.HostGroupId', HostGroups[depth1].get('HostGroupId'))
			if HostGroups[depth1].get('NodeCount') is not None:
				self.add_query_param('HostGroup.' + str(depth1 + 1) + '.NodeCount', HostGroups[depth1].get('NodeCount'))
			if HostGroups[depth1].get('InstanceType') is not None:
				self.add_query_param('HostGroup.' + str(depth1 + 1) + '.InstanceType', HostGroups[depth1].get('InstanceType'))
			if HostGroups[depth1].get('Comment') is not None:
				self.add_query_param('HostGroup.' + str(depth1 + 1) + '.Comment', HostGroups[depth1].get('Comment'))
			if HostGroups[depth1].get('ChargeType') is not None:
				self.add_query_param('HostGroup.' + str(depth1 + 1) + '.ChargeType', HostGroups[depth1].get('ChargeType'))
			if HostGroups[depth1].get('MultiInstanceTypes') is not None:
				self.add_query_param('HostGroup.' + str(depth1 + 1) + '.MultiInstanceTypes', HostGroups[depth1].get('MultiInstanceTypes'))
			if HostGroups[depth1].get('CreateType') is not None:
				self.add_query_param('HostGroup.' + str(depth1 + 1) + '.CreateType', HostGroups[depth1].get('CreateType'))
			if HostGroups[depth1].get('HostGroupType') is not None:
				self.add_query_param('HostGroup.' + str(depth1 + 1) + '.HostGroupType', HostGroups[depth1].get('HostGroupType'))
			if HostGroups[depth1].get('PrivatePoolOptionsMatchCriteria') is not None:
				self.add_query_param('HostGroup.' + str(depth1 + 1) + '.PrivatePoolOptionsMatchCriteria', HostGroups[depth1].get('PrivatePoolOptionsMatchCriteria'))

	def get_Configs(self):
		return self.get_query_params().get('Config')

	def set_Configs(self, Configs):
		for depth1 in range(len(Configs)):
			if Configs[depth1].get('ConfigKey') is not None:
				self.add_query_param('Config.' + str(depth1 + 1) + '.ConfigKey', Configs[depth1].get('ConfigKey'))
			if Configs[depth1].get('FileName') is not None:
				self.add_query_param('Config.' + str(depth1 + 1) + '.FileName', Configs[depth1].get('FileName'))
			if Configs[depth1].get('Encrypt') is not None:
				self.add_query_param('Config.' + str(depth1 + 1) + '.Encrypt', Configs[depth1].get('Encrypt'))
			if Configs[depth1].get('Replace') is not None:
				self.add_query_param('Config.' + str(depth1 + 1) + '.Replace', Configs[depth1].get('Replace'))
			if Configs[depth1].get('ConfigValue') is not None:
				self.add_query_param('Config.' + str(depth1 + 1) + '.ConfigValue', Configs[depth1].get('ConfigValue'))
			if Configs[depth1].get('ServiceName') is not None:
				self.add_query_param('Config.' + str(depth1 + 1) + '.ServiceName', Configs[depth1].get('ServiceName'))

	def get_HighAvailabilityEnable(self):
		return self.get_query_params().get('HighAvailabilityEnable')

	def set_HighAvailabilityEnable(self,HighAvailabilityEnable):
		self.add_query_param('HighAvailabilityEnable',HighAvailabilityEnable)