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
from aliyunsdksas.endpoint import endpoint_data

class GetClientRatioStatisticRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Sas', '2018-12-03', 'GetClientRatioStatistic','sas')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_TimeEnd(self): # Long
		return self.get_query_params().get('TimeEnd')

	def set_TimeEnd(self, TimeEnd):  # Long
		self.add_query_param('TimeEnd', TimeEnd)
	def get_ResourceDirectoryAccountId(self): # Long
		return self.get_query_params().get('ResourceDirectoryAccountId')

	def set_ResourceDirectoryAccountId(self, ResourceDirectoryAccountId):  # Long
		self.add_query_param('ResourceDirectoryAccountId', ResourceDirectoryAccountId)
	def get_StatisticTypes(self): # Array
		return self.get_query_params().get('StatisticTypes')

	def set_StatisticTypes(self, StatisticTypes):  # Array
		for index1, value1 in enumerate(StatisticTypes):
			self.add_query_param('StatisticTypes.' + str(index1 + 1), value1)
	def get_TimeStart(self): # Long
		return self.get_query_params().get('TimeStart')

	def set_TimeStart(self, TimeStart):  # Long
		self.add_query_param('TimeStart', TimeStart)
