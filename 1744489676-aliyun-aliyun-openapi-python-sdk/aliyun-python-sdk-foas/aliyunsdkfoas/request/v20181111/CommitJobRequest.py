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

from aliyunsdkcore.request import RoaRequest
from aliyunsdkfoas.endpoint import endpoint_data

class CommitJobRequest(RoaRequest):

	def __init__(self):
		RoaRequest.__init__(self, 'foas', '2018-11-11', 'CommitJob','foas')
		self.set_protocol_type('https')
		self.set_uri_pattern('/api/v2/projects/[projectName]/jobs/[jobName]/commit')
		self.set_method('PUT')
		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())


	def get_projectName(self):
		return self.get_path_params().get('projectName')

	def set_projectName(self,projectName):
		self.add_path_param('projectName',projectName)

	def get_recommendOnly(self):
		return self.get_body_params().get('recommendOnly')

	def set_recommendOnly(self,recommendOnly):
		self.add_body_params('recommendOnly', recommendOnly)

	def get_suspendPeriods(self):
		return self.get_body_params().get('suspendPeriods')

	def set_suspendPeriods(self,suspendPeriods):
		self.add_body_params('suspendPeriods', suspendPeriods)

	def get_maxCU(self):
		return self.get_body_params().get('maxCU')

	def set_maxCU(self,maxCU):
		self.add_body_params('maxCU', maxCU)

	def get_configure(self):
		return self.get_body_params().get('configure')

	def set_configure(self,configure):
		self.add_body_params('configure', configure)

	def get_isOnOff(self):
		return self.get_body_params().get('isOnOff')

	def set_isOnOff(self,isOnOff):
		self.add_body_params('isOnOff', isOnOff)

	def get_jobName(self):
		return self.get_path_params().get('jobName')

	def set_jobName(self,jobName):
		self.add_path_param('jobName',jobName)

	def get_suspendPeriodParams(self):
		return self.get_body_params().get('suspendPeriodParam')

	def set_suspendPeriodParams(self, suspendPeriodParams):
		for depth1 in range(len(suspendPeriodParams)):
			if suspendPeriodParams[depth1].get('endTime') is not None:
				self.add_body_params('suspendPeriodParam.' + str(depth1 + 1) + '.endTime', suspendPeriodParams[depth1].get('endTime'))
			if suspendPeriodParams[depth1].get('startTime') is not None:
				self.add_body_params('suspendPeriodParam.' + str(depth1 + 1) + '.startTime', suspendPeriodParams[depth1].get('startTime'))
			if suspendPeriodParams[depth1].get('plan') is not None:
				self.add_body_params('suspendPeriodParam.' + str(depth1 + 1) + '.plan', suspendPeriodParams[depth1].get('plan'))
			if suspendPeriodParams[depth1].get('policy') is not None:
				self.add_body_params('suspendPeriodParam.' + str(depth1 + 1) + '.policy', suspendPeriodParams[depth1].get('policy'))