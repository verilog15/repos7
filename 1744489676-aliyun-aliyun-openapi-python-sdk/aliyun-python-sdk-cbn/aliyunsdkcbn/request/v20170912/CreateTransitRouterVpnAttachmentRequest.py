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
from aliyunsdkcbn.endpoint import endpoint_data

class CreateTransitRouterVpnAttachmentRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Cbn', '2017-09-12', 'CreateTransitRouterVpnAttachment','cbn')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_ResourceOwnerId(self): # Long
		return self.get_query_params().get('ResourceOwnerId')

	def set_ResourceOwnerId(self, ResourceOwnerId):  # Long
		self.add_query_param('ResourceOwnerId', ResourceOwnerId)
	def get_ClientToken(self): # String
		return self.get_query_params().get('ClientToken')

	def set_ClientToken(self, ClientToken):  # String
		self.add_query_param('ClientToken', ClientToken)
	def get_CenId(self): # String
		return self.get_query_params().get('CenId')

	def set_CenId(self, CenId):  # String
		self.add_query_param('CenId', CenId)
	def get_TransitRouterAttachmentName(self): # String
		return self.get_query_params().get('TransitRouterAttachmentName')

	def set_TransitRouterAttachmentName(self, TransitRouterAttachmentName):  # String
		self.add_query_param('TransitRouterAttachmentName', TransitRouterAttachmentName)
	def get_Zones(self): # RepeatList
		return self.get_query_params().get('Zone')

	def set_Zones(self, Zone):  # RepeatList
		for depth1 in range(len(Zone)):
			if Zone[depth1].get('ZoneId') is not None:
				self.add_query_param('Zone.' + str(depth1 + 1) + '.ZoneId', Zone[depth1].get('ZoneId'))
	def get_Tags(self): # RepeatList
		return self.get_query_params().get('Tag')

	def set_Tags(self, Tag):  # RepeatList
		for depth1 in range(len(Tag)):
			if Tag[depth1].get('Value') is not None:
				self.add_query_param('Tag.' + str(depth1 + 1) + '.Value', Tag[depth1].get('Value'))
			if Tag[depth1].get('Key') is not None:
				self.add_query_param('Tag.' + str(depth1 + 1) + '.Key', Tag[depth1].get('Key'))
	def get_AutoPublishRouteEnabled(self): # Boolean
		return self.get_query_params().get('AutoPublishRouteEnabled')

	def set_AutoPublishRouteEnabled(self, AutoPublishRouteEnabled):  # Boolean
		self.add_query_param('AutoPublishRouteEnabled', AutoPublishRouteEnabled)
	def get_DryRun(self): # Boolean
		return self.get_query_params().get('DryRun')

	def set_DryRun(self, DryRun):  # Boolean
		self.add_query_param('DryRun', DryRun)
	def get_ResourceOwnerAccount(self): # String
		return self.get_query_params().get('ResourceOwnerAccount')

	def set_ResourceOwnerAccount(self, ResourceOwnerAccount):  # String
		self.add_query_param('ResourceOwnerAccount', ResourceOwnerAccount)
	def get_OwnerAccount(self): # String
		return self.get_query_params().get('OwnerAccount')

	def set_OwnerAccount(self, OwnerAccount):  # String
		self.add_query_param('OwnerAccount', OwnerAccount)
	def get_OwnerId(self): # Long
		return self.get_query_params().get('OwnerId')

	def set_OwnerId(self, OwnerId):  # Long
		self.add_query_param('OwnerId', OwnerId)
	def get_TransitRouterId(self): # String
		return self.get_query_params().get('TransitRouterId')

	def set_TransitRouterId(self, TransitRouterId):  # String
		self.add_query_param('TransitRouterId', TransitRouterId)
	def get_TransitRouterAttachmentDescription(self): # String
		return self.get_query_params().get('TransitRouterAttachmentDescription')

	def set_TransitRouterAttachmentDescription(self, TransitRouterAttachmentDescription):  # String
		self.add_query_param('TransitRouterAttachmentDescription', TransitRouterAttachmentDescription)
	def get_VpnOwnerId(self): # Long
		return self.get_query_params().get('VpnOwnerId')

	def set_VpnOwnerId(self, VpnOwnerId):  # Long
		self.add_query_param('VpnOwnerId', VpnOwnerId)
	def get_ChargeType(self): # String
		return self.get_query_params().get('ChargeType')

	def set_ChargeType(self, ChargeType):  # String
		self.add_query_param('ChargeType', ChargeType)
	def get_VpnId(self): # String
		return self.get_query_params().get('VpnId')

	def set_VpnId(self, VpnId):  # String
		self.add_query_param('VpnId', VpnId)
