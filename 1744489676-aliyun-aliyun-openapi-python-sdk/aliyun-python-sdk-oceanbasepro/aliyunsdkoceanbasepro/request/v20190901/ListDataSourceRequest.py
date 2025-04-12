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
from aliyunsdkoceanbasepro.endpoint import endpoint_data
import json

class ListDataSourceRequest(RpcRequest):

	def __init__(self):
		RpcRequest.__init__(self, 'OceanBasePro', '2019-09-01', 'ListDataSource','oceanbase')
		self.set_method('POST')

		if hasattr(self, "endpoint_map"):
			setattr(self, "endpoint_map", endpoint_data.getEndpointMap())
		if hasattr(self, "endpoint_regional"):
			setattr(self, "endpoint_regional", endpoint_data.getEndpointRegional())

	def get_Types(self): # Array
		return self.get_body_params().get('Types')

	def set_Types(self, Types):  # Array
		self.add_body_params("Types", json.dumps(Types))
	def get_SearchKey(self): # String
		return self.get_body_params().get('SearchKey')

	def set_SearchKey(self, SearchKey):  # String
		self.add_body_params('SearchKey', SearchKey)
	def get_PageNumber(self): # String
		return self.get_body_params().get('PageNumber')

	def set_PageNumber(self, PageNumber):  # String
		self.add_body_params('PageNumber', PageNumber)
	def get_PageSize(self): # String
		return self.get_body_params().get('PageSize')

	def set_PageSize(self, PageSize):  # String
		self.add_body_params('PageSize', PageSize)
	def get_SortField(self): # String
		return self.get_body_params().get('SortField')

	def set_SortField(self, SortField):  # String
		self.add_body_params('SortField', SortField)
	def get_Order(self): # String
		return self.get_body_params().get('Order')

	def set_Order(self, Order):  # String
		self.add_body_params('Order', Order)
