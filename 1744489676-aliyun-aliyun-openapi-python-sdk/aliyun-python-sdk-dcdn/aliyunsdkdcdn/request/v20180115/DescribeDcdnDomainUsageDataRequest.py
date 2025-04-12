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
from aliyunsdkdcdn.endpoint import endpoint_data

class DescribeDcdnDomainUsageDataRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'dcdn', '2018-01-15', 'DescribeDcdnDomainUsageData')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_Area(self): # String
		return self.get_query_params().get('Area')

	def set_Area(self, Area):  # String
		self.add_query_param('Area', Area)
	def get_Field(self): # String
		return self.get_query_params().get('Field')

	def set_Field(self, Field):  # String
		self.add_query_param('Field', Field)
	def get_DomainName(self): # String
		return self.get_query_params().get('DomainName')

	def set_DomainName(self, DomainName):  # String
		self.add_query_param('DomainName', DomainName)
	def get_EndTime(self): # String
		return self.get_query_params().get('EndTime')

	def set_EndTime(self, EndTime):  # String
		self.add_query_param('EndTime', EndTime)
	def get_Interval(self): # String
		return self.get_query_params().get('Interval')

	def set_Interval(self, Interval):  # String
		self.add_query_param('Interval', Interval)
	def get_StartTime(self): # String
		return self.get_query_params().get('StartTime')

	def set_StartTime(self, StartTime):  # String
		self.add_query_param('StartTime', StartTime)
	def get_Type(self): # String
		return self.get_query_params().get('Type')

	def set_Type(self, Type):  # String
		self.add_query_param('Type', Type)
	def get_DataProtocol(self): # String
		return self.get_query_params().get('DataProtocol')

	def set_DataProtocol(self, DataProtocol):  # String
		self.add_query_param('DataProtocol', DataProtocol)
