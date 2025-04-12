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

class DescribeSiteMonitorISPCityListRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Cms', '2019-01-01', 'DescribeSiteMonitorISPCityList','cms')
		self.set_method('POST')

	def get_City(self): # String
		return self.get_query_params().get('City')

	def set_City(self, City):  # String
		self.add_query_param('City', City)
	def get_Isp(self): # String
		return self.get_query_params().get('Isp')

	def set_Isp(self, Isp):  # String
		self.add_query_param('Isp', Isp)
	def get_ViewAll(self): # Boolean
		return self.get_query_params().get('ViewAll')

	def set_ViewAll(self, ViewAll):  # Boolean
		self.add_query_param('ViewAll', ViewAll)
	def get_IPV4(self): # Boolean
		return self.get_query_params().get('IPV4')

	def set_IPV4(self, IPV4):  # Boolean
		self.add_query_param('IPV4', IPV4)
	def get_IPV6(self): # Boolean
		return self.get_query_params().get('IPV6')

	def set_IPV6(self, IPV6):  # Boolean
		self.add_query_param('IPV6', IPV6)
