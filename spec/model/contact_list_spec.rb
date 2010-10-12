$:.unshift File.join(File.dirname(__FILE__),'..')
require 'configuration'
require 'slideshare/model'

include Slideshare

describe ContactList do

  describe "from_xml providing a complete an xml document with just one Contact definition" do
    before(:all) do
        xml=%q{
          <Contacts>
           <Contact>
           </Contact>
          </Contacts>
          }
      @response=ContactList.from_xml xml
    end

    it "invoking :items returns a list with one Contact " do
      @response.items.count.should == 1
    end

    it "items single item is a Contact " do
      @response.items.first.should be_kind_of Contact
    end
  end

    describe "from_xml providing a complete an xml document with two Contact definitions" do
        before(:all) do
        xml=%q{
           <Contacts>
           <Contact>
            <Username>miguelff</Username>
            <NumComments>100</NumComments>
            <NumSlideshows>200</NumSlideshows>
           </Contact>
            <Contact>
            </Contact>
          </Contacts>
          }
      @response=ContactList.from_xml xml
    end

    it "invoking :items returns a list with two Contacts " do
      @response.items.count.should == 2
    end

    it "each item is a Contact " do
      @response.items.each do |item|
        item.should be_kind_of Contact
      end
    end

    it "first contact is populated" do
      @response.first.should be_kind_of Contact
      @response.first.name.should == "miguelff"
      @response.first.num_slideshows.should == 200
      @response.first.num_comments.should == 100
    end
  end

  it "doesn't fail if document contains no Contact definitions" do
    xml=%q{
     <Contacts/>
    }
    contactList=ContactList.from_xml xml
    contactList.methods(false).count.should == ContactList.extraction_rules.size*2
  end

end

