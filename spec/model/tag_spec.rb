$:.unshift File.join(File.dirname(__FILE__),'..')
require 'configuration'
require 'slideshare/model'

include Slideshare

describe Tag do

  describe "from_xml providing a definition with every attribute" do
    before(:all) do
        xml=%{<Tag Owner="1" Count="1">tiempo real</Tag>}
      @tag=Tag.from_xml xml
    end

    it "should set the proper value for :name" do
      @tag.name.should == "tiempo real"
    end

    it "should set the proper value for :times_used" do
      @tag.times_used.should == 1
    end

    it "should set the proper value for :used_by_owner" do
      @tag.used_by_owner.should be_true
    end

  end

  it "doesn't fail if document contains no data" do
    xml=%{<Tag/>}
    tag=Tag.from_xml xml
    tag.methods(false).count.should == (Tag.extraction_rules.size-1)*2
  end

end

