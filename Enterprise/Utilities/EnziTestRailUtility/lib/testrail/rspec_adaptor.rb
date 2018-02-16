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
require 'testrail/adaptor'

module TestRail

  class RSpecAdaptor < Adaptor

    # Submits an example test results
    # If the test case exists, it will reuse the id, otherwise it will create a new Test Case in TestRails
    # @param example [RSpec::Core::Example] A test case example after execution
    def submit(example)
      return unless @enabled
      test_case_section = example.example_group.description.strip
      test_case_name = example.description.strip
      test_result = example.exception.nil?
      test_comment = example.exception

      submit_test_result(
        section_name: test_case_section,
        test_name: test_case_name,
        success: test_result,
        comment: test_comment
      )
    end

  end

end
