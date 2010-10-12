$:.unshift File.join(File.dirname(__FILE__),'..')
require 'configuration'
require 'slideshare/model'

include Slideshare

describe TagList do

  describe "from_xml providing a complete an xml document with just one Tag definition" do
    before(:each) do
        xml=%q{
          <Tags>
            <Tag Owner="1" Count="10">
            </Tag>
          </Tags>
          }
      @response=TagList.from_xml xml
    end

    it "invoking :items returns a list with one Tag " do
      @response.items.count.should == 1
    end

    it "items single item is a Tag " do
      @response.items.first.should be_kind_of Tag
    end

    it "items single item is used by owner " do
      @response.items.first.used_by_owner.should be_true
    end
  end

    describe "from_xml providing a complete an xml document with two Tag definitions" do
        before(:each) do
        xml=%q{
           <Tags>
            <Tag>
            </Tag>
            <Tag>
            </Tag>
          </Tags>
          }
      @response=TagList.from_xml xml
    end

    it "invoking :items returns a list with two Tags " do
      @response.items.count.should == 2
    end

    it "each item is a Tag " do
      @response.items.each do |item|
        item.should be_kind_of Tag
      end
    end
  end

  it "doesn't fail if document contains no Tag definitions" do
    xml=%q{
     <Tags/>
    }
    tagList=TagList.from_xml xml
    tagList.methods(false).count.should == TagList.extraction_rules.size*2
  end

end

