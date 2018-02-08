require 'rspec'
describe "test" do
  it "test1" do
    if !ENV['PROJECT_ID'].nil? && ENV['SUIT_ID'].nil? && ENV['SECTION_ID'].nil? then
      Kernel.exec("ruby specManager.rb project:#{ENV['PROJECT_ID']}")
    else
      if !ENV['SUIT_ID'].nil? && ENV['PROJECT_ID'].nil? && ENV['SECTION_ID'].nil? then
        Kernel.exec("ruby specManager.rb suit:#{ENV['SUIT_ID']}")
      else
        if !ENV['SECTION_ID'].nil? && ENV['PROJECT_ID'].nil? && ENV['SUIT_ID'].nil? then
          Kernel.exec("ruby specManager.rb section:#{ENV['SECTION_ID']}")
        else
          Kernel.exec("ruby specManager.rb project:#{ENV['PROJECT_ID']} suit:#{ENV['SUIT_ID']} section:#{ENV['SECTION_ID']}")
        end
      end
    end
  end
end
