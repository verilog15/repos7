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

class SetGWSClusterPolicyRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'EHPC', '2018-04-12', 'SetGWSClusterPolicy','ehs')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_Watermark(self): # String
		return self.get_query_params().get('Watermark')

	def set_Watermark(self, Watermark):  # String
		self.add_query_param('Watermark', Watermark)
	def get_LocalDrive(self): # String
		return self.get_query_params().get('LocalDrive')

	def set_LocalDrive(self, LocalDrive):  # String
		self.add_query_param('LocalDrive', LocalDrive)
	def get_ClusterId(self): # String
		return self.get_query_params().get('ClusterId')

	def set_ClusterId(self, ClusterId):  # String
		self.add_query_param('ClusterId', ClusterId)
	def get_Clipboard(self): # String
		return self.get_query_params().get('Clipboard')

	def set_Clipboard(self, Clipboard):  # String
		self.add_query_param('Clipboard', Clipboard)
	def get_UsbRedirect(self): # String
		return self.get_query_params().get('UsbRedirect')

	def set_UsbRedirect(self, UsbRedirect):  # String
		self.add_query_param('UsbRedirect', UsbRedirect)
	def get_AsyncMode(self): # Boolean
		return self.get_query_params().get('AsyncMode')

	def set_AsyncMode(self, AsyncMode):  # Boolean
		self.add_query_param('AsyncMode', AsyncMode)
	def get_UdpPort(self): # String
		return self.get_query_params().get('UdpPort')

	def set_UdpPort(self, UdpPort):  # String
		self.add_query_param('UdpPort', UdpPort)
