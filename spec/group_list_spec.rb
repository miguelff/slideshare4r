require 'slideshare/model'

include Slideshare

describe GroupList do

  describe "from_xml providing a complete an xml document with just one Group definition" do
    before(:each) do
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
        before(:each) do
        xml=%q{
          <Groups>
            <Group>
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
  end

  it "doesn't fail if document contains no Group definitions" do
    xml=%q{
     <Groups/>
    }
    grouplist=GroupList.from_xml xml
    grouplist.methods(false).count.should == GroupList.extraction_rules.size*2
  end

end

