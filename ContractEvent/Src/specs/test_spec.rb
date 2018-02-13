#Created By : Kishor Shinde
#Created Date : 28/12/2017
#Modified date :
require_relative '../../src/pageObjects/mergeOpportunitiesPage'
require "selenium-webdriver"
require "rspec"

describe "MergeOpportunities" do
	before(:all){
		@driver = Selenium::WebDriver.for :chrome
	}

		before(:each){
			puts "before each"
		}

		context "context1" do
			before(:all){
			puts @driver.current_url();
			}
		      before(:each){
			puts "context1:before each"
			}

			puts "context1"
			it "it1" do
				puts "it1"
				puts @driver.current_url();
				
			end
			
			after(:all){
				puts "context1:after all"
				puts @driver.current_url();
			}

			after(:each){
				puts "context1:after each"
				puts @driver.current_url();
			}
		end

		
	after(:all){
		puts "after all"
	}

	after(:each){
		puts "after each"
	}

end