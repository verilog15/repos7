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
from aliyunsdkalidns.endpoint import endpoint_data

class UpdateDnsGtmInstanceGlobalConfigRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Alidns', '2015-01-09', 'UpdateDnsGtmInstanceGlobalConfig','alidns')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_AlertGroup(self): # String
		return self.get_query_params().get('AlertGroup')

	def set_AlertGroup(self, AlertGroup):  # String
		self.add_query_param('AlertGroup', AlertGroup)
	def get_CnameType(self): # String
		return self.get_query_params().get('CnameType')

	def set_CnameType(self, CnameType):  # String
		self.add_query_param('CnameType', CnameType)
	def get_Lang(self): # String
		return self.get_query_params().get('Lang')

	def set_Lang(self, Lang):  # String
		self.add_query_param('Lang', Lang)
	def get_AlertConfigs(self): # RepeatList
		return self.get_query_params().get('AlertConfig')

	def set_AlertConfigs(self, AlertConfig):  # RepeatList
		for depth1 in range(len(AlertConfig)):
			if AlertConfig[depth1].get('DingtalkNotice') is not None:
				self.add_query_param('AlertConfig.' + str(depth1 + 1) + '.DingtalkNotice', AlertConfig[depth1].get('DingtalkNotice'))
			if AlertConfig[depth1].get('SmsNotice') is not None:
				self.add_query_param('AlertConfig.' + str(depth1 + 1) + '.SmsNotice', AlertConfig[depth1].get('SmsNotice'))
			if AlertConfig[depth1].get('NoticeType') is not None:
				self.add_query_param('AlertConfig.' + str(depth1 + 1) + '.NoticeType', AlertConfig[depth1].get('NoticeType'))
			if AlertConfig[depth1].get('EmailNotice') is not None:
				self.add_query_param('AlertConfig.' + str(depth1 + 1) + '.EmailNotice', AlertConfig[depth1].get('EmailNotice'))
	def get_PublicCnameMode(self): # String
		return self.get_query_params().get('PublicCnameMode')

	def set_PublicCnameMode(self, PublicCnameMode):  # String
		self.add_query_param('PublicCnameMode', PublicCnameMode)
	def get_PublicUserDomainName(self): # String
		return self.get_query_params().get('PublicUserDomainName')

	def set_PublicUserDomainName(self, PublicUserDomainName):  # String
		self.add_query_param('PublicUserDomainName', PublicUserDomainName)
	def get_Ttl(self): # Integer
		return self.get_query_params().get('Ttl')

	def set_Ttl(self, Ttl):  # Integer
		self.add_query_param('Ttl', Ttl)
	def get_ForceUpdate(self): # Boolean
		return self.get_query_params().get('ForceUpdate')

	def set_ForceUpdate(self, ForceUpdate):  # Boolean
		self.add_query_param('ForceUpdate', ForceUpdate)
	def get_InstanceId(self): # String
		return self.get_query_params().get('InstanceId')

	def set_InstanceId(self, InstanceId):  # String
		self.add_query_param('InstanceId', InstanceId)
	def get_InstanceName(self): # String
		return self.get_query_params().get('InstanceName')

	def set_InstanceName(self, InstanceName):  # String
		self.add_query_param('InstanceName', InstanceName)
	def get_PublicRr(self): # String
		return self.get_query_params().get('PublicRr')

	def set_PublicRr(self, PublicRr):  # String
		self.add_query_param('PublicRr', PublicRr)
	def get_PublicZoneName(self): # String
		return self.get_query_params().get('PublicZoneName')

	def set_PublicZoneName(self, PublicZoneName):  # String
		self.add_query_param('PublicZoneName', PublicZoneName)
