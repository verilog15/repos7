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
from aliyunsdkalinlp.endpoint import endpoint_data

class GetMedicineChMedicalRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'alinlp', '2020-06-29', 'GetMedicineChMedical','alinlp')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_Factory(self): # String
		return self.get_body_params().get('Factory')

	def set_Factory(self, Factory):  # String
		self.add_body_params('Factory', Factory)
	def get_Specification(self): # String
		return self.get_body_params().get('Specification')

	def set_Specification(self, Specification):  # String
		self.add_body_params('Specification', Specification)
	def get_Unit(self): # String
		return self.get_body_params().get('Unit')

	def set_Unit(self, Unit):  # String
		self.add_body_params('Unit', Unit)
	def get_ServiceCode(self): # String
		return self.get_body_params().get('ServiceCode')

	def set_ServiceCode(self, ServiceCode):  # String
		self.add_body_params('ServiceCode', ServiceCode)
	def get_Name(self): # String
		return self.get_body_params().get('Name')

	def set_Name(self, Name):  # String
		self.add_body_params('Name', Name)
