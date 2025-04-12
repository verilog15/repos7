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
from aliyunsdkdataworks_public.endpoint import endpoint_data

class UpdateDIJobRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'dataworks-public', '2020-05-18', 'UpdateDIJob')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_Description(self): # String
		return self.get_body_params().get('Description')

	def set_Description(self, Description):  # String
		self.add_body_params('Description', Description)
	def get_TransformationRules(self): # String
		return self.get_body_params().get('TransformationRules')

	def set_TransformationRules(self, TransformationRules):  # String
		self.add_body_params('TransformationRules', TransformationRules)
	def get_DIJobId(self): # Long
		return self.get_body_params().get('DIJobId')

	def set_DIJobId(self, DIJobId):  # Long
		self.add_body_params('DIJobId', DIJobId)
	def get_ResourceSettings(self): # String
		return self.get_body_params().get('ResourceSettings')

	def set_ResourceSettings(self, ResourceSettings):  # String
		self.add_body_params('ResourceSettings', ResourceSettings)
	def get_TableMappings(self): # String
		return self.get_body_params().get('TableMappings')

	def set_TableMappings(self, TableMappings):  # String
		self.add_body_params('TableMappings', TableMappings)
	def get_JobSettings(self): # String
		return self.get_body_params().get('JobSettings')

	def set_JobSettings(self, JobSettings):  # String
		self.add_body_params('JobSettings', JobSettings)
