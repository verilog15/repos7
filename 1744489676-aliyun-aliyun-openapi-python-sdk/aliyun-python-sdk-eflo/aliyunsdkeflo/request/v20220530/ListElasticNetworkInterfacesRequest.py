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

class ListElasticNetworkInterfacesRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'eflo', '2022-05-30', 'ListElasticNetworkInterfaces','eflo')
		self.set_method('POST')

	def get_NetworkType(self): # String
		return self.get_body_params().get('NetworkType')

	def set_NetworkType(self, NetworkType):  # String
		self.add_body_params('NetworkType', NetworkType)
	def get_Type(self): # String
		return self.get_body_params().get('Type')

	def set_Type(self, Type):  # String
		self.add_body_params('Type', Type)
	def get_PageNumber(self): # Integer
		return self.get_body_params().get('PageNumber')

	def set_PageNumber(self, PageNumber):  # Integer
		self.add_body_params('PageNumber', PageNumber)
	def get_PageSize(self): # Integer
		return self.get_body_params().get('PageSize')

	def set_PageSize(self, PageSize):  # Integer
		self.add_body_params('PageSize', PageSize)
	def get_NodeId(self): # String
		return self.get_body_params().get('NodeId')

	def set_NodeId(self, NodeId):  # String
		self.add_body_params('NodeId', NodeId)
	def get_Ip(self): # String
		return self.get_body_params().get('Ip')

	def set_Ip(self, Ip):  # String
		self.add_body_params('Ip', Ip)
	def get_VSwitchId(self): # String
		return self.get_body_params().get('VSwitchId')

	def set_VSwitchId(self, VSwitchId):  # String
		self.add_body_params('VSwitchId', VSwitchId)
	def get_VpcId(self): # String
		return self.get_body_params().get('VpcId')

	def set_VpcId(self, VpcId):  # String
		self.add_body_params('VpcId', VpcId)
	def get_ZoneId(self): # String
		return self.get_body_params().get('ZoneId')

	def set_ZoneId(self, ZoneId):  # String
		self.add_body_params('ZoneId', ZoneId)
	def get_ElasticNetworkInterfaceId(self): # String
		return self.get_body_params().get('ElasticNetworkInterfaceId')

	def set_ElasticNetworkInterfaceId(self, ElasticNetworkInterfaceId):  # String
		self.add_body_params('ElasticNetworkInterfaceId', ElasticNetworkInterfaceId)
	def get_Status(self): # String
		return self.get_body_params().get('Status')

	def set_Status(self, Status):  # String
		self.add_body_params('Status', Status)
