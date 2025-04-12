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
from aliyunsdksae.endpoint import endpoint_data

class CreateJobRequest(RoaRequest):

	def __init__(self):
		RoaRequest.__init__(self, 'sae', '2019-05-06', 'CreateJob','serverless')
		self.set_uri_pattern('/pop/v1/sam/job/createJob')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_NasId(self): # String
		return self.get_query_params().get('NasId')

	def set_NasId(self, NasId):  # String
		self.add_query_param('NasId', NasId)
	def get_JarStartArgs(self): # String
		return self.get_query_params().get('JarStartArgs')

	def set_JarStartArgs(self, JarStartArgs):  # String
		self.add_query_param('JarStartArgs', JarStartArgs)
	def get_ConcurrencyPolicy(self): # String
		return self.get_query_params().get('ConcurrencyPolicy')

	def set_ConcurrencyPolicy(self, ConcurrencyPolicy):  # String
		self.add_query_param('ConcurrencyPolicy', ConcurrencyPolicy)
	def get_TriggerConfig(self): # String
		return self.get_query_params().get('TriggerConfig')

	def set_TriggerConfig(self, TriggerConfig):  # String
		self.add_query_param('TriggerConfig', TriggerConfig)
	def get_OssAkSecret(self): # String
		return self.get_body_params().get('OssAkSecret')

	def set_OssAkSecret(self, OssAkSecret):  # String
		self.add_body_params('OssAkSecret', OssAkSecret)
	def get_MountHost(self): # String
		return self.get_query_params().get('MountHost')

	def set_MountHost(self, MountHost):  # String
		self.add_query_param('MountHost', MountHost)
	def get_AutoConfig(self): # Boolean
		return self.get_query_params().get('AutoConfig')

	def set_AutoConfig(self, AutoConfig):  # Boolean
		self.add_query_param('AutoConfig', AutoConfig)
	def get_Envs(self): # String
		return self.get_query_params().get('Envs')

	def set_Envs(self, Envs):  # String
		self.add_query_param('Envs', Envs)
	def get_ProgrammingLanguage(self): # String
		return self.get_query_params().get('ProgrammingLanguage')

	def set_ProgrammingLanguage(self, ProgrammingLanguage):  # String
		self.add_query_param('ProgrammingLanguage', ProgrammingLanguage)
	def get_CustomHostAlias(self): # String
		return self.get_query_params().get('CustomHostAlias')

	def set_CustomHostAlias(self, CustomHostAlias):  # String
		self.add_query_param('CustomHostAlias', CustomHostAlias)
	def get_JarStartOptions(self): # String
		return self.get_query_params().get('JarStartOptions')

	def set_JarStartOptions(self, JarStartOptions):  # String
		self.add_query_param('JarStartOptions', JarStartOptions)
	def get_AppName(self): # String
		return self.get_query_params().get('AppName')

	def set_AppName(self, AppName):  # String
		self.add_query_param('AppName', AppName)
	def get_NamespaceId(self): # String
		return self.get_query_params().get('NamespaceId')

	def set_NamespaceId(self, NamespaceId):  # String
		self.add_query_param('NamespaceId', NamespaceId)
	def get_Slice(self): # Boolean
		return self.get_query_params().get('Slice')

	def set_Slice(self, Slice):  # Boolean
		self.add_query_param('Slice', Slice)
	def get_ConfigMapMountDesc(self): # String
		return self.get_body_params().get('ConfigMapMountDesc')

	def set_ConfigMapMountDesc(self, ConfigMapMountDesc):  # String
		self.add_body_params('ConfigMapMountDesc', ConfigMapMountDesc)
	def get_OssMountDescs(self): # String
		return self.get_body_params().get('OssMountDescs')

	def set_OssMountDescs(self, OssMountDescs):  # String
		self.add_body_params('OssMountDescs', OssMountDescs)
	def get_ImagePullSecrets(self): # String
		return self.get_query_params().get('ImagePullSecrets')

	def set_ImagePullSecrets(self, ImagePullSecrets):  # String
		self.add_query_param('ImagePullSecrets', ImagePullSecrets)
	def get_PreStop(self): # String
		return self.get_query_params().get('PreStop')

	def set_PreStop(self, PreStop):  # String
		self.add_query_param('PreStop', PreStop)
	def get_Python(self): # String
		return self.get_query_params().get('Python')

	def set_Python(self, Python):  # String
		self.add_query_param('Python', Python)
	def get_Cpu(self): # Integer
		return self.get_query_params().get('Cpu')

	def set_Cpu(self, Cpu):  # Integer
		self.add_query_param('Cpu', Cpu)
	def get_BackoffLimit(self): # Long
		return self.get_query_params().get('BackoffLimit')

	def set_BackoffLimit(self, BackoffLimit):  # Long
		self.add_query_param('BackoffLimit', BackoffLimit)
	def get_VSwitchId(self): # String
		return self.get_query_params().get('VSwitchId')

	def set_VSwitchId(self, VSwitchId):  # String
		self.add_query_param('VSwitchId', VSwitchId)
	def get_PackageType(self): # String
		return self.get_query_params().get('PackageType')

	def set_PackageType(self, PackageType):  # String
		self.add_query_param('PackageType', PackageType)
	def get_PostStart(self): # String
		return self.get_query_params().get('PostStart')

	def set_PostStart(self, PostStart):  # String
		self.add_query_param('PostStart', PostStart)
	def get_WebContainer(self): # String
		return self.get_query_params().get('WebContainer')

	def set_WebContainer(self, WebContainer):  # String
		self.add_query_param('WebContainer', WebContainer)
	def get_Memory(self): # Integer
		return self.get_query_params().get('Memory')

	def set_Memory(self, Memory):  # Integer
		self.add_query_param('Memory', Memory)
	def get_SlsConfigs(self): # String
		return self.get_query_params().get('SlsConfigs')

	def set_SlsConfigs(self, SlsConfigs):  # String
		self.add_query_param('SlsConfigs', SlsConfigs)
	def get_CommandArgs(self): # String
		return self.get_query_params().get('CommandArgs')

	def set_CommandArgs(self, CommandArgs):  # String
		self.add_query_param('CommandArgs', CommandArgs)
	def get_AcrAssumeRoleArn(self): # String
		return self.get_query_params().get('AcrAssumeRoleArn')

	def set_AcrAssumeRoleArn(self, AcrAssumeRoleArn):  # String
		self.add_query_param('AcrAssumeRoleArn', AcrAssumeRoleArn)
	def get_Timezone(self): # String
		return self.get_query_params().get('Timezone')

	def set_Timezone(self, Timezone):  # String
		self.add_query_param('Timezone', Timezone)
	def get_OssAkId(self): # String
		return self.get_body_params().get('OssAkId')

	def set_OssAkId(self, OssAkId):  # String
		self.add_body_params('OssAkId', OssAkId)
	def get_SecurityGroupId(self): # String
		return self.get_query_params().get('SecurityGroupId')

	def set_SecurityGroupId(self, SecurityGroupId):  # String
		self.add_query_param('SecurityGroupId', SecurityGroupId)
	def get_PackageVersion(self): # String
		return self.get_query_params().get('PackageVersion')

	def set_PackageVersion(self, PackageVersion):  # String
		self.add_query_param('PackageVersion', PackageVersion)
	def get_TomcatConfig(self): # String
		return self.get_query_params().get('TomcatConfig')

	def set_TomcatConfig(self, TomcatConfig):  # String
		self.add_query_param('TomcatConfig', TomcatConfig)
	def get_Timeout(self): # Long
		return self.get_query_params().get('Timeout')

	def set_Timeout(self, Timeout):  # Long
		self.add_query_param('Timeout', Timeout)
	def get_WarStartOptions(self): # String
		return self.get_query_params().get('WarStartOptions')

	def set_WarStartOptions(self, WarStartOptions):  # String
		self.add_query_param('WarStartOptions', WarStartOptions)
	def get_EdasContainerVersion(self): # String
		return self.get_query_params().get('EdasContainerVersion')

	def set_EdasContainerVersion(self, EdasContainerVersion):  # String
		self.add_query_param('EdasContainerVersion', EdasContainerVersion)
	def get_PackageUrl(self): # String
		return self.get_query_params().get('PackageUrl')

	def set_PackageUrl(self, PackageUrl):  # String
		self.add_query_param('PackageUrl', PackageUrl)
	def get_TerminationGracePeriodSeconds(self): # Integer
		return self.get_query_params().get('TerminationGracePeriodSeconds')

	def set_TerminationGracePeriodSeconds(self, TerminationGracePeriodSeconds):  # Integer
		self.add_query_param('TerminationGracePeriodSeconds', TerminationGracePeriodSeconds)
	def get_PhpConfig(self): # String
		return self.get_body_params().get('PhpConfig')

	def set_PhpConfig(self, PhpConfig):  # String
		self.add_body_params('PhpConfig', PhpConfig)
	def get_SliceEnvs(self): # String
		return self.get_query_params().get('SliceEnvs')

	def set_SliceEnvs(self, SliceEnvs):  # String
		self.add_query_param('SliceEnvs', SliceEnvs)
	def get_EnableImageAccl(self): # Boolean
		return self.get_body_params().get('EnableImageAccl')

	def set_EnableImageAccl(self, EnableImageAccl):  # Boolean
		self.add_body_params('EnableImageAccl', EnableImageAccl)
	def get_Replicas(self): # Integer
		return self.get_query_params().get('Replicas')

	def set_Replicas(self, Replicas):  # Integer
		self.add_query_param('Replicas', Replicas)
	def get_Workload(self): # String
		return self.get_query_params().get('Workload')

	def set_Workload(self, Workload):  # String
		self.add_query_param('Workload', Workload)
	def get_Command(self): # String
		return self.get_query_params().get('Command')

	def set_Command(self, Command):  # String
		self.add_query_param('Command', Command)
	def get_MountDesc(self): # String
		return self.get_query_params().get('MountDesc')

	def set_MountDesc(self, MountDesc):  # String
		self.add_query_param('MountDesc', MountDesc)
	def get_Jdk(self): # String
		return self.get_query_params().get('Jdk')

	def set_Jdk(self, Jdk):  # String
		self.add_query_param('Jdk', Jdk)
	def get_AppDescription(self): # String
		return self.get_query_params().get('AppDescription')

	def set_AppDescription(self, AppDescription):  # String
		self.add_query_param('AppDescription', AppDescription)
	def get_AcrInstanceId(self): # String
		return self.get_body_params().get('AcrInstanceId')

	def set_AcrInstanceId(self, AcrInstanceId):  # String
		self.add_body_params('AcrInstanceId', AcrInstanceId)
	def get_VpcId(self): # String
		return self.get_query_params().get('VpcId')

	def set_VpcId(self, VpcId):  # String
		self.add_query_param('VpcId', VpcId)
	def get_ImageUrl(self): # String
		return self.get_query_params().get('ImageUrl')

	def set_ImageUrl(self, ImageUrl):  # String
		self.add_query_param('ImageUrl', ImageUrl)
	def get_RefAppId(self): # String
		return self.get_query_params().get('RefAppId')

	def set_RefAppId(self, RefAppId):  # String
		self.add_query_param('RefAppId', RefAppId)
	def get_PythonModules(self): # String
		return self.get_query_params().get('PythonModules')

	def set_PythonModules(self, PythonModules):  # String
		self.add_query_param('PythonModules', PythonModules)
	def get_PhpConfigLocation(self): # String
		return self.get_query_params().get('PhpConfigLocation')

	def set_PhpConfigLocation(self, PhpConfigLocation):  # String
		self.add_query_param('PhpConfigLocation', PhpConfigLocation)
