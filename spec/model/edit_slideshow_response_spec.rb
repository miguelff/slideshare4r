$:.unshift File.join(File.dirname(__FILE__),'..')
require 'configuration'
require 'slideshare/model'

include Slideshare

describe EditSlideshowResponse do

  describe "from_xml providing a complete an xml document with the response" do
    before(:all) do
        xml=%q{
          <SlideShowEdited>
            <SlideShowID>SlideShowID</SlideShowID>
          </SlideShowEdited>
          }
      @response=EditSlideshowResponse.from_xml xml
    end

    it "invoking :slideshow_id returns the id of the edited slideshow " do
      @response.slideshow_id.should == "SlideShowID"
    end

    it "invoking :success returns true " do
      @response.success.should be_true
    end
  end

   describe "from_xml providing a complete an xml document with the response" do
    before(:all) do
        xml=%q{
          <SlideShowEdited/>
          }
      @response=EditSlideshowResponse.from_xml xml
    end

    it "invoking :slideshow_id returns the id of the edited slideshow " do
      @response.slideshow_id.should be_empty
    end

    it "invoking :success returns true " do
      @response.success.should be_false
    end
  end
end
