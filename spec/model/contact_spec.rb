$:.unshift File.join(File.dirname(__FILE__),'..')
require 'configuration'
require 'slideshare/model'

include Slideshare

describe Contact do

  describe "from_xml providing a complete xml document" do
    before(:all) do
        xml=%q{
           <Contact>
            <Username>miguelff</Username>
            <NumComments>100</NumComments>
            <NumSlideshows>200</NumSlideshows>
           </Contact>
          }
      @group=Contact.from_xml xml
    end

    it "should set the proper value for :name" do
      @group.name.should == "miguelff"
    end

    it "should set the proper value for :num_comments" do
      @group.num_comments.should == 100
    end

    it "should set the proper value for :num_slideshows" do
      @group.num_slideshows.should == 200
    end

  end

  it "doesn't fail if document contains no data" do
    xml=%q{
     <Contact/>
    }
    contact=Contact.from_xml xml
    contact.methods(false).count.should == Contact.extraction_rules.size*2
  end

end

