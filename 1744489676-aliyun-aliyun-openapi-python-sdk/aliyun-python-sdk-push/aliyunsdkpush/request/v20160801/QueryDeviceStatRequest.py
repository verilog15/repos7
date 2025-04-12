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
from aliyunsdkpush.endpoint import endpoint_data

class QueryDeviceStatRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Push', '2016-08-01', 'QueryDeviceStat')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_EndTime(self): # String
		return self.get_query_params().get('EndTime')

	def set_EndTime(self, EndTime):  # String
		self.add_query_param('EndTime', EndTime)
	def get_StartTime(self): # String
		return self.get_query_params().get('StartTime')

	def set_StartTime(self, StartTime):  # String
		self.add_query_param('StartTime', StartTime)
	def get_DeviceType(self): # String
		return self.get_query_params().get('DeviceType')

	def set_DeviceType(self, DeviceType):  # String
		self.add_query_param('DeviceType', DeviceType)
	def get_AppKey(self): # Long
		return self.get_query_params().get('AppKey')

	def set_AppKey(self, AppKey):  # Long
		self.add_query_param('AppKey', AppKey)
	def get_QueryType(self): # String
		return self.get_query_params().get('QueryType')

	def set_QueryType(self, QueryType):  # String
		self.add_query_param('QueryType', QueryType)
