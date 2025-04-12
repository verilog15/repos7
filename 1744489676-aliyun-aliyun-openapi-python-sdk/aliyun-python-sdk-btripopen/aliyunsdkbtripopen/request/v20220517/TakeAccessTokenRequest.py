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

class TakeAccessTokenRequest(RoaRequest):

	def __init__(self):
		RoaRequest.__init__(self, 'btripOpen', '2022-05-17', 'TakeAccessToken')
		self.set_protocol_type('https')
		self.set_uri_pattern('/btrip/open/access-token/take')
		self.set_method('GET')

	def get_app_key(self): # String
		return self.get_query_params().get('app_key')

	def set_app_key(self, app_key):  # String
		self.add_query_param('app_key', app_key)
	def get_app_secret(self): # String
		return self.get_query_params().get('app_secret')

	def set_app_secret(self, app_secret):  # String
		self.add_query_param('app_secret', app_secret)
