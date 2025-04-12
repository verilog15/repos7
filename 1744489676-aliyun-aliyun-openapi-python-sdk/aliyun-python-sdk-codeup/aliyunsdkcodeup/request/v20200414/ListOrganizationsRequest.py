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

class ListOrganizationsRequest(RoaRequest):

	def __init__(self):
		RoaRequest.__init__(self, 'codeup', '2020-04-14', 'ListOrganizations')
		self.set_uri_pattern('/api/v4/organization')
		self.set_method('GET')

	def get_AccessLevel(self):
		return self.get_query_params().get('AccessLevel')

	def set_AccessLevel(self,AccessLevel):
		self.add_query_param('AccessLevel',AccessLevel)

	def get_MinAccessLevel(self):
		return self.get_query_params().get('MinAccessLevel')

	def set_MinAccessLevel(self,MinAccessLevel):
		self.add_query_param('MinAccessLevel',MinAccessLevel)

	def get_AccessToken(self):
		return self.get_query_params().get('AccessToken')

	def set_AccessToken(self,AccessToken):
		self.add_query_param('AccessToken',AccessToken)