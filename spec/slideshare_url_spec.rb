require 'util'

include Slideshare

describe URL do
  
  it "should compose a correct URL when only a path is provided" do
    URL.new("path").url.should eql("http://www.slideshare.net/api/2/path")
    URL.new(3).url.should eql("http://www.slideshare.net/api/2/3")
  end
  
  it "should compose a correct URL when path and args are provided" do
    URL.new("path",:a=>1, :b=>2).url.should eql("http://www.slideshare.net/api/2/path?a=1&b=2")
  end
  
  it "should fail to build a correct URL if no path is provided" do
     lambda{URL.new(nil)}.should raise_error
  end

  
end