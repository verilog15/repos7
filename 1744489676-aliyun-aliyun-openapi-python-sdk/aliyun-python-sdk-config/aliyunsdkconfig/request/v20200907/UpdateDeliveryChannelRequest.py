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
from aliyunsdkconfig.endpoint import endpoint_data

class UpdateDeliveryChannelRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'Config', '2020-09-07', 'UpdateDeliveryChannel','config')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_NonCompliantNotification(self): # Boolean
		return self.get_body_params().get('NonCompliantNotification')

	def set_NonCompliantNotification(self, NonCompliantNotification):  # Boolean
		self.add_body_params('NonCompliantNotification', NonCompliantNotification)
	def get_ClientToken(self): # String
		return self.get_body_params().get('ClientToken')

	def set_ClientToken(self, ClientToken):  # String
		self.add_body_params('ClientToken', ClientToken)
	def get_ConfigurationSnapshot(self): # Boolean
		return self.get_body_params().get('ConfigurationSnapshot')

	def set_ConfigurationSnapshot(self, ConfigurationSnapshot):  # Boolean
		self.add_body_params('ConfigurationSnapshot', ConfigurationSnapshot)
	def get_Description(self): # String
		return self.get_body_params().get('Description')

	def set_Description(self, Description):  # String
		self.add_body_params('Description', Description)
	def get_DeliveryChannelTargetArn(self): # String
		return self.get_body_params().get('DeliveryChannelTargetArn')

	def set_DeliveryChannelTargetArn(self, DeliveryChannelTargetArn):  # String
		self.add_body_params('DeliveryChannelTargetArn', DeliveryChannelTargetArn)
	def get_DeliveryChannelCondition(self): # String
		return self.get_body_params().get('DeliveryChannelCondition')

	def set_DeliveryChannelCondition(self, DeliveryChannelCondition):  # String
		self.add_body_params('DeliveryChannelCondition', DeliveryChannelCondition)
	def get_ConfigurationItemChangeNotification(self): # Boolean
		return self.get_body_params().get('ConfigurationItemChangeNotification')

	def set_ConfigurationItemChangeNotification(self, ConfigurationItemChangeNotification):  # Boolean
		self.add_body_params('ConfigurationItemChangeNotification', ConfigurationItemChangeNotification)
	def get_DeliveryChannelAssumeRoleArn(self): # String
		return self.get_body_params().get('DeliveryChannelAssumeRoleArn')

	def set_DeliveryChannelAssumeRoleArn(self, DeliveryChannelAssumeRoleArn):  # String
		self.add_body_params('DeliveryChannelAssumeRoleArn', DeliveryChannelAssumeRoleArn)
	def get_DeliveryChannelName(self): # String
		return self.get_body_params().get('DeliveryChannelName')

	def set_DeliveryChannelName(self, DeliveryChannelName):  # String
		self.add_body_params('DeliveryChannelName', DeliveryChannelName)
	def get_DeliveryChannelId(self): # String
		return self.get_body_params().get('DeliveryChannelId')

	def set_DeliveryChannelId(self, DeliveryChannelId):  # String
		self.add_body_params('DeliveryChannelId', DeliveryChannelId)
	def get_OversizedDataOSSTargetArn(self): # String
		return self.get_body_params().get('OversizedDataOSSTargetArn')

	def set_OversizedDataOSSTargetArn(self, OversizedDataOSSTargetArn):  # String
		self.add_body_params('OversizedDataOSSTargetArn', OversizedDataOSSTargetArn)
	def get_Status(self): # Long
		return self.get_body_params().get('Status')

	def set_Status(self, Status):  # Long
		self.add_body_params('Status', Status)
