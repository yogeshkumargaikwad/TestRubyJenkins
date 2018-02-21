#Created By : Kishor Shinde
#Created Date : 28/12/2017
#Modified date :
require "rspec"

describe "MergeOpportunities" do
  before(:all){
    puts "22222222222222"

  }

  before(:each){
    puts "before each"
  }

  context "context1" do
    before(:all){
=begin
      projectId = ENV['PROJECT_ID']
      puts  projectId
      suitId = ENV['SUIT_ID']
      puts suitId
      sectionId =  ENV['SECTION_ID']
      puts sectionId
=end
    }
    before(:each){
      puts "context1:before each"
    }
    it "it1", :"1" => true do
      puts "it1"
    end

    it "it2", :"2" => true do
      puts "it2"
    end
    it "it3", :"3" => true do
      puts "it3"
    end

    after(:all){
      puts "context1:after all"
    }

    after(:each){
      puts "context1:after each"
    }
     end
  after(:all){
    puts "after all"
  }

  after(:each){
    puts "after each"
  }

end