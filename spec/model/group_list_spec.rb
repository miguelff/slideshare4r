$:.unshift File.join(File.dirname(__FILE__),'..')
require 'configuration'
require 'slideshare/model'

include Slideshare

describe GroupList do

  describe "from_xml providing a complete an xml document with just one Group definition" do
    before(:all) do
        xml=%q{
          <Groups>
            <Group>
            </Group>
          </Groups>
          }
      @response=GroupList.from_xml xml
    end

    it "invoking :items returns a list with one group " do
      @response.items.count.should == 1
    end

    it "items single item is a group " do
      @response.items.first.should be_kind_of Group
    end
  end

    describe "from_xml providing a complete an xml document with two Group definitions" do
        before(:all) do
        xml=%q{
          <Groups>
            <Group>
              <Name>Viajes, Travels, Voyages</Name>
              <NumPosts>100</NumPosts>
              <NumSlideshows>200</NumSlideshows>
              <NumMembers>3</NumMembers>
              <Created>Sat Sep 18 08:09:00 -0500 2010</Created>
              <QueryName>viajes-travels-voyages</QueryName>
              <URL>http://www.slideshare.net/group/viajes-travels-voyages</URL>
            </Group>
            <Group>
            </Group>
          </Groups>
          }
      @response=GroupList.from_xml xml
    end

    it "invoking :items returns a list with two groups " do
      @response.items.count.should == 2
    end

    it "each item is a Group " do
      @response.items.each do |item|
        item.should be_kind_of Group
      end
    end

    it "first group is populated" do
      @response.first.should be_kind_of Group
      @response.first.name.should == "Viajes, Travels, Voyages"
      @response.first.num_posts.should == 100
    end
  end

  it "doesn't fail if document contains no Group definitions" do
    xml=%q{
     <Groups/>
    }
    grouplist=GroupList.from_xml xml
    grouplist.methods(false).count.should == GroupList.extraction_rules.size*2
  end

end

