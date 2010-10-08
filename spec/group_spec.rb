require 'slideshare/model'

describe Group do

  describe "from_xml providing a complete xml document" do
    before(:all) do
        xml=%q{
           <Group>
            <Name>Viajes, Travels, Voyages</Name>
            <NumPosts>100</NumPosts>
            <NumSlideshows>200</NumSlideshows>
            <NumMembers>3</NumMembers>
            <Created>Sat Sep 18 08:09:00 -0500 2010</Created>
            <QueryName>viajes-travels-voyages</QueryName>
            <URL>http://www.slideshare.net/group/viajes-travels-voyages</URL>
           <Group>
          }
      @group=Group.from_xml xml
    end

    it "should set the proper value for :name" do
      @group.name.should == "Viajes, Travels, Voyages"
    end

    it "should set the proper value for :num_posts" do
      @group.num_posts.should == 100
    end

    it "should set the proper value for :num_slideshows" do
      @group.num_slideshows.should == 200
    end

    it "should set the proper value for :num_members" do
      @group.num_members.should == 3
    end

    it "should set the proper value for :created" do
      @group.created.should == DateTime.parse("2010-09-18T08:09:00-05:00")
    end

    it "should set the proper value for :query_name" do
      @group.query_name.should == "viajes-travels-voyages"
    end

    it "should set the proper value for :query_name" do
      @group.url.should == "http://www.slideshare.net/group/viajes-travels-voyages"
    end

  end

  it "doesn't fail if document contains no data" do
    xml=%q{
     <Group/>
    }
    group=Group.from_xml xml
    group.methods(false).count.should == Group.extraction_rules.size*2
  end
  
end

