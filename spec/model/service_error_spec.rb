$:.unshift File.join(File.dirname(__FILE__),'..')
require 'configuration'
require 'slideshare/model'

include Slideshare

describe ServiceError do

  describe "from_xml providing a definition with every attribute" do
    before(:all) do
        xml=%{
          <SlideShareServiceError>
                 <Message ID="0">No API Key Provided</Message>
          </SlideShareServiceError>
              }
      @error=ServiceError.from_xml xml
      
    end

    it "should set the proper value for :message" do
      @error.message.should == "No API Key Provided"
    end

    it "should set the proper value for :code" do
      @error.code.should == 0
    end

  end

  it "doesn't fail if document contains no data" do
    xml=%{<SlideShareServiceError/>}
    lambda{ServiceError.from_xml xml}.should_not raise_error
  end

end

