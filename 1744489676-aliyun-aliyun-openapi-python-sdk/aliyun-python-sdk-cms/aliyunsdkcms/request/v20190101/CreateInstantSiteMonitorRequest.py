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

class CreateInstantSiteMonitorRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Cms', '2019-01-01', 'CreateInstantSiteMonitor','cms')
		self.set_method('POST')

	def get_RandomIspCity(self): # Integer
		return self.get_query_params().get('RandomIspCity')

	def set_RandomIspCity(self, RandomIspCity):  # Integer
		self.add_query_param('RandomIspCity', RandomIspCity)
	def get_Address(self): # String
		return self.get_query_params().get('Address')

	def set_Address(self, Address):  # String
		self.add_query_param('Address', Address)
	def get_TaskType(self): # String
		return self.get_query_params().get('TaskType')

	def set_TaskType(self, TaskType):  # String
		self.add_query_param('TaskType', TaskType)
	def get_TaskName(self): # String
		return self.get_query_params().get('TaskName')

	def set_TaskName(self, TaskName):  # String
		self.add_query_param('TaskName', TaskName)
	def get_IspCities(self): # String
		return self.get_query_params().get('IspCities')

	def set_IspCities(self, IspCities):  # String
		self.add_query_param('IspCities', IspCities)
	def get_OptionsJson(self): # String
		return self.get_query_params().get('OptionsJson')

	def set_OptionsJson(self, OptionsJson):  # String
		self.add_query_param('OptionsJson', OptionsJson)
