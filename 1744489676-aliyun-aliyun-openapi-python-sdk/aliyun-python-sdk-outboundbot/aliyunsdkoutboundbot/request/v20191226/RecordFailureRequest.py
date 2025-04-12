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
from aliyunsdkoutboundbot.endpoint import endpoint_data

class RecordFailureRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'OutboundBot', '2019-12-26', 'RecordFailure')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_CallId(self): # String
		return self.get_query_params().get('CallId')

	def set_CallId(self, CallId):  # String
		self.add_query_param('CallId', CallId)
	def get_ActualTime(self): # Long
		return self.get_query_params().get('ActualTime')

	def set_ActualTime(self, ActualTime):  # Long
		self.add_query_param('ActualTime', ActualTime)
	def get_CallingNumber(self): # String
		return self.get_query_params().get('CallingNumber')

	def set_CallingNumber(self, CallingNumber):  # String
		self.add_query_param('CallingNumber', CallingNumber)
	def get_InstanceId(self): # String
		return self.get_query_params().get('InstanceId')

	def set_InstanceId(self, InstanceId):  # String
		self.add_query_param('InstanceId', InstanceId)
	def get_DispositionCode(self): # String
		return self.get_query_params().get('DispositionCode')

	def set_DispositionCode(self, DispositionCode):  # String
		self.add_query_param('DispositionCode', DispositionCode)
	def get_CalledNumber(self): # String
		return self.get_query_params().get('CalledNumber')

	def set_CalledNumber(self, CalledNumber):  # String
		self.add_query_param('CalledNumber', CalledNumber)
	def get_TaskId(self): # String
		return self.get_query_params().get('TaskId')

	def set_TaskId(self, TaskId):  # String
		self.add_query_param('TaskId', TaskId)
	def get_ExceptionCodes(self): # String
		return self.get_query_params().get('ExceptionCodes')

	def set_ExceptionCodes(self, ExceptionCodes):  # String
		self.add_query_param('ExceptionCodes', ExceptionCodes)
