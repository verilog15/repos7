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
from aliyunsdkehpc.endpoint import endpoint_data

class UpdateClusterVolumesRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'EHPC', '2018-04-12', 'UpdateClusterVolumes','ehs')
		self.set_method('GET')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_AdditionalVolumess(self): # RepeatList
		return self.get_query_params().get('AdditionalVolumes')

	def set_AdditionalVolumess(self, AdditionalVolumes):  # RepeatList
		for depth1 in range(len(AdditionalVolumes)):
			if AdditionalVolumes[depth1].get('VolumeType') is not None:
				self.add_query_param('AdditionalVolumes.' + str(depth1 + 1) + '.VolumeType', AdditionalVolumes[depth1].get('VolumeType'))
			if AdditionalVolumes[depth1].get('VolumeProtocol') is not None:
				self.add_query_param('AdditionalVolumes.' + str(depth1 + 1) + '.VolumeProtocol', AdditionalVolumes[depth1].get('VolumeProtocol'))
			if AdditionalVolumes[depth1].get('VolumeMountOption') is not None:
				self.add_query_param('AdditionalVolumes.' + str(depth1 + 1) + '.VolumeMountOption', AdditionalVolumes[depth1].get('VolumeMountOption'))
			if AdditionalVolumes[depth1].get('LocalDirectory') is not None:
				self.add_query_param('AdditionalVolumes.' + str(depth1 + 1) + '.LocalDirectory', AdditionalVolumes[depth1].get('LocalDirectory'))
			if AdditionalVolumes[depth1].get('RemoteDirectory') is not None:
				self.add_query_param('AdditionalVolumes.' + str(depth1 + 1) + '.RemoteDirectory', AdditionalVolumes[depth1].get('RemoteDirectory'))
			if AdditionalVolumes[depth1].get('Roles') is not None:
				for depth2 in range(len(AdditionalVolumes[depth1].get('Roles'))):
					if AdditionalVolumes[depth1].get('Roles')[depth2].get('Name') is not None:
						self.add_query_param('AdditionalVolumes.' + str(depth1 + 1) + '.Roles.'  + str(depth2 + 1) + '.Name', AdditionalVolumes[depth1].get('Roles')[depth2].get('Name'))
			if AdditionalVolumes[depth1].get('VolumeId') is not None:
				self.add_query_param('AdditionalVolumes.' + str(depth1 + 1) + '.VolumeId', AdditionalVolumes[depth1].get('VolumeId'))
			if AdditionalVolumes[depth1].get('VolumeMountpoint') is not None:
				self.add_query_param('AdditionalVolumes.' + str(depth1 + 1) + '.VolumeMountpoint', AdditionalVolumes[depth1].get('VolumeMountpoint'))
			if AdditionalVolumes[depth1].get('Location') is not None:
				self.add_query_param('AdditionalVolumes.' + str(depth1 + 1) + '.Location', AdditionalVolumes[depth1].get('Location'))
			if AdditionalVolumes[depth1].get('JobQueue') is not None:
				self.add_query_param('AdditionalVolumes.' + str(depth1 + 1) + '.JobQueue', AdditionalVolumes[depth1].get('JobQueue'))
	def get_ClusterId(self): # String
		return self.get_query_params().get('ClusterId')

	def set_ClusterId(self, ClusterId):  # String
		self.add_query_param('ClusterId', ClusterId)
