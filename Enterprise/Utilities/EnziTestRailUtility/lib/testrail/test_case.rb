# Copyright 2016 Findly Inc. NZ
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'testrail/test_result'

module TestRail

  class TestCase

    attr_reader :id, :name, :section

    def initialize(id:, name:, section:, testrail_client:)
      raise(ArgumentError, 'test case id nil') if id.nil?
      raise(ArgumentError, 'test case name nil') if name.nil?
      @id = id
      @name = name
      @section = section
      @testrail_client = testrail_client
    end

    def create_result(success:, comment:)
      TestResult.new(test_case: self, success: success, comment: comment)
    end

  end

end
