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

class ModifyDiskReplicaPairRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'ebs', '2021-07-30', 'ModifyDiskReplicaPair','ebs')
		self.set_method('POST')

	def get_PairName(self): # String
		return self.get_query_params().get('PairName')

	def set_PairName(self, PairName):  # String
		self.add_query_param('PairName', PairName)
	def get_ClientToken(self): # String
		return self.get_query_params().get('ClientToken')

	def set_ClientToken(self, ClientToken):  # String
		self.add_query_param('ClientToken', ClientToken)
	def get_Description(self): # String
		return self.get_query_params().get('Description')

	def set_Description(self, Description):  # String
		self.add_query_param('Description', Description)
	def get_Bandwidth(self): # Long
		return self.get_query_params().get('Bandwidth')

	def set_Bandwidth(self, Bandwidth):  # Long
		self.add_query_param('Bandwidth', Bandwidth)
	def get_ReplicaPairId(self): # String
		return self.get_query_params().get('ReplicaPairId')

	def set_ReplicaPairId(self, ReplicaPairId):  # String
		self.add_query_param('ReplicaPairId', ReplicaPairId)
	def get_RPO(self): # Long
		return self.get_query_params().get('RPO')

	def set_RPO(self, RPO):  # Long
		self.add_query_param('RPO', RPO)
