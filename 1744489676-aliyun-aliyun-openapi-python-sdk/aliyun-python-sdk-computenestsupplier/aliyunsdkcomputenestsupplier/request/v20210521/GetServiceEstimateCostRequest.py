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
from aliyunsdkcomputenestsupplier.endpoint import endpoint_data
import json

class GetServiceEstimateCostRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'ComputeNestSupplier', '2021-05-21', 'GetServiceEstimateCost')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_Commodity(self): # Struct
		return self.get_query_params().get('Commodity')

	def set_Commodity(self, Commodity):  # Struct
		self.add_query_param("Commodity", json.dumps(Commodity))
	def get_ClientToken(self): # String
		return self.get_query_params().get('ClientToken')

	def set_ClientToken(self, ClientToken):  # String
		self.add_query_param('ClientToken', ClientToken)
	def get_TemplateName(self): # String
		return self.get_query_params().get('TemplateName')

	def set_TemplateName(self, TemplateName):  # String
		self.add_query_param('TemplateName', TemplateName)
	def get_ServiceInstanceId(self): # String
		return self.get_query_params().get('ServiceInstanceId')

	def set_ServiceInstanceId(self, ServiceInstanceId):  # String
		self.add_query_param('ServiceInstanceId', ServiceInstanceId)
	def get_SpecificationName(self): # String
		return self.get_query_params().get('SpecificationName')

	def set_SpecificationName(self, SpecificationName):  # String
		self.add_query_param('SpecificationName', SpecificationName)
	def get_ServiceVersion(self): # String
		return self.get_query_params().get('ServiceVersion')

	def set_ServiceVersion(self, ServiceVersion):  # String
		self.add_query_param('ServiceVersion', ServiceVersion)
	def get_ServiceId(self): # String
		return self.get_query_params().get('ServiceId')

	def set_ServiceId(self, ServiceId):  # String
		self.add_query_param('ServiceId', ServiceId)
	def get_Parameters(self): # String
		return self.get_query_params().get('Parameters')

	def set_Parameters(self, Parameters):  # String
		self.add_query_param('Parameters', Parameters)
