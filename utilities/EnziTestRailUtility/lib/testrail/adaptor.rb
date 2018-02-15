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

require 'testrail/api_client'
require 'testrail/testrail_client'

module TestRail

  class Adaptor

    def initialize(
      enabled: true,
      test_suite: nil,
      url:,
      username:,
      password:,
      project_id:,
      suite_id:
    )
      @enabled = enabled
      return unless @enabled
      if test_suite.nil?
        testrail_client = TestRail::APIClient.new(url)
        testrail_client.user = username
        testrail_client.password = password
        @test_suite = TestRail::TestRailClient.new(testrail_client).get_suite(
          project_id: project_id,
          suite_id: suite_id
        )
      else
        @test_suite = test_suite
      end
    end

    # A new test result is submitted to TestRails. The type of test depends on the Test Suite
    # Each adaptor implementation should be able to determine the required information
    # from the test provided as a parameter
    def submit(_test)
      raise 'submit should be overrided by Adaptor implementations'
    end

    # This method initiates a test run against a project, and specified testsuite.
    # ruby functional test file (.rb) containing a range of test cases.
    # Each test case (in the ruby functional test file) will have a corresponding Test Case in TestRail.
    # These Test Rail test cases will belong to a test suite that has the title of the corresponding
    # ruby functional test file.
    def start_test_run
      return unless @enabled
      @test_run = @test_suite.start_test_run
    end

    # Checks to see if any of the tests in a particular test run have failed, if they have then the
    # it will leave the run opened. If there are no failed tests then it will call close the particular run.
    def end_test_run
      return if !@enabled || @test_run.nil?
      @test_run.submit_results
      @test_run.close unless @test_run.failure_count > 0
    end

    protected

    def submit_test_result(
      section_name:,
      test_name:,
      success:,
      comment:
    )
      @test_run.add_test_result(
        section_name: section_name,
        test_name: test_name,
        success: success,
        comment: comment
      )
    end

  end

end
