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

module TestRail

  class TestRun

    def initialize(suite:, id:)
      @suite = suite
      @id = id
      @results = []
    end

    def add_test_result(section_name:, test_name:, success:, comment: nil)
      @results << @suite
                  .get_or_create_section(section_name)
                  .get_or_create_test_case(test_name)
                  .create_result(success: success, comment: comment)
    end

    def submit_results
      @suite.submit_test_results(run_id: @id, results: @results)
    end

    def close
      @suite.close_test_run(@id)
    end

    def failure_count
      @results.count { |r| !r.success? }
    end

  end

end
