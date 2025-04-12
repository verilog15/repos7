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

class DescribeSiteMonitorLogRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Cms', '2019-01-01', 'DescribeSiteMonitorLog','cms')
		self.set_method('POST')

	def get_BrowserInfo(self): # String
		return self.get_query_params().get('BrowserInfo')

	def set_BrowserInfo(self, BrowserInfo):  # String
		self.add_query_param('BrowserInfo', BrowserInfo)
	def get_City(self): # String
		return self.get_query_params().get('City')

	def set_City(self, City):  # String
		self.add_query_param('City', City)
	def get_Isp(self): # String
		return self.get_query_params().get('Isp')

	def set_Isp(self, Isp):  # String
		self.add_query_param('Isp', Isp)
	def get_StartTime(self): # String
		return self.get_query_params().get('StartTime')

	def set_StartTime(self, StartTime):  # String
		self.add_query_param('StartTime', StartTime)
	def get_TaskIds(self): # String
		return self.get_query_params().get('TaskIds')

	def set_TaskIds(self, TaskIds):  # String
		self.add_query_param('TaskIds', TaskIds)
	def get_NextToken(self): # String
		return self.get_query_params().get('NextToken')

	def set_NextToken(self, NextToken):  # String
		self.add_query_param('NextToken', NextToken)
	def get_Browser(self): # String
		return self.get_query_params().get('Browser')

	def set_Browser(self, Browser):  # String
		self.add_query_param('Browser', Browser)
	def get_MetricName(self): # String
		return self.get_query_params().get('MetricName')

	def set_MetricName(self, MetricName):  # String
		self.add_query_param('MetricName', MetricName)
	def get_Length(self): # Integer
		return self.get_query_params().get('Length')

	def set_Length(self, Length):  # Integer
		self.add_query_param('Length', Length)
	def get_EndTime(self): # String
		return self.get_query_params().get('EndTime')

	def set_EndTime(self, EndTime):  # String
		self.add_query_param('EndTime', EndTime)
	def get_Filter(self): # String
		return self.get_query_params().get('Filter')

	def set_Filter(self, Filter):  # String
		self.add_query_param('Filter', Filter)
	def get_Device(self): # String
		return self.get_query_params().get('Device')

	def set_Device(self, Device):  # String
		self.add_query_param('Device', Device)
