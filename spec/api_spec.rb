require 'slideshare'

include Slideshare

describe API do
  it "should initialize when every required argument is provided" do
    API.new "foo","bar"
  end

  it "should failed initializitaion when not every required argument is provided" do
    lambda{API.new}.should raise_error
  end

  it "should failed initializitaion when either api_key or shared_secret is nil" do
    lambda{API.new nil,"xxx"}.should raise_error(ArgumentError)
    lambda{API.new "xxx",nil}.should raise_error(ArgumentError)
    lambda{API.new nil,nil}.should raise_error(ArgumentError)
  end

  it "should failed initializitaion when neither api_key nor shared_secret is a string " do
    lambda{API.new "xxx",4}.should raise_error(ArgumentError)
    lambda{API.new 4,"xxx"}.should raise_error(ArgumentError)
    lambda{API.new 4,4}.should raise_error(ArgumentError)
  end
  
  it "should set properties properly when optional arguments are provided" do
    slideshare=API.new "foo","bar",:proxy_host=>"proxy.host.com",:proxy_port=>8888,:proxy_user=>"proxy_user",:proxy_pass=>"proxy_pass"
    slideshare.api_key.should eql("foo")
    slideshare.shared_secret.should eql("bar")
    slideshare.proxy.should eql(Proxy.new("proxy.host.com",8888,"proxy_user","proxy_pass"))
  end
  
  it "should fail initialization if you provide a proxy_host but not a proxy_port" do
    lambda{API.new "foo","bar",:proxy_host=>"proxy.foo.com"}.should raise_error
  end
  
  it "should fail initialization if proxy port is not a number between 0 and 65535" do
    lambda{API.new "foo","bar",:proxy_host=>"proxy.foo.com",:proxy_port=>"wrong"}.should raise_error(ArgumentError)
    lambda{API.new "foo","bar",:proxy_host=>"proxy.foo.com",:proxy_port=>65536}.should raise_error(ArgumentError)
    lambda{API.new "foo","bar",:proxy_host=>"proxy.foo.com",:proxy_port=>-1}.should raise_error(ArgumentError)
    lambda{API.new "foo","bar",:proxy_host=>"proxy.foo.com",:proxy_port=>8888}.should_not raise_error(ArgumentError)
  end
  

  
  describe "get_slideshow" do
    before(:each) do
      @api=API.new Config::API_KEY, Config::SHARED_SECRET, :proxy_host=>Config::PROXY_HOST, :proxy_port=>Config::PROXY_PORT
    end 
    
    it "should raise an error if neither :slideshow_id nor :slideshow_url are provided" do
      lambda{@api.get_slideshow}.should raise_error(ArgumentError)
    end
    
    it "should not raise an error if either :slideshow_id or :slideshow_url are provided" do
      lambda{@api.get_slideshow :slideshow_id=>Config::SAMPLE_SLIDESHOW_ID}.should_not raise_error(ArgumentError)
      lambda{ @api.get_slideshow :slideshow_url=>Config::SAMPLE_SLIDESHOW_URL}.should_not raise_error(ArgumentError)
    end
    
    it "should raise an error if :exclude_tags is neither true nor false" do
      lambda{@api.get_slideshow :slideshow_url=>Config::SAMPLE_SLIDESHOW_URL, :exclude_tags=>1}.should raise_error(ArgumentError)
    end
    
    it "should raise an error if :detailed is neither true nor false" do
      lambda{@api.get_slideshow :slideshow_url=>Config::SAMPLE_SLIDESHOW_URL, :detailed=>1}.should raise_error(ArgumentError)
    end

    
    it "should retrieve detailed content when requested" do
      slideshow=@api.get_slideshow(:slideshow_url=>Config::SAMPLE_SLIDESHOW_URL, :detailed=>true)
      slideshow.should_not be_nil
      slideshow.should be_a_kind_of Slideshow
      slideshow.user_id.should_not be_empty

    end
  end

  describe "get_slideshows_by_tag" do
    before(:each) do
      @api=API.new Config::API_KEY, Config::SHARED_SECRET, :proxy_host=>Config::PROXY_HOST, :proxy_port=>Config::PROXY_PORT
    end

    it "should raise an error if :tag is not provided" do
      lambda{@api.get_slideshows_by_tag}.should raise_error(ArgumentError)
    end

    it "should raise an error  if :tag is not a string" do
      lambda{@api.get_slideshows_by_tag :tag=>3}.should raise_error(ArgumentError)
      lambda{@api.get_slideshows_by_tag :tag=>nil}.should raise_error(ArgumentError)
    end


    it "should raise an error if :detailed is neither true nor false" do
      lambda{@api.get_slideshows_by_tag :tag=>"foo", :detailed=>1}.should raise_error(ArgumentError)
    end

    it "should raise an error if :limit is not a positive integer" do
      lambda{@api.get_slideshows_by_tag :tag=>"foo", :limit=>0}.should raise_error(ArgumentError)
      lambda{@api.get_slideshows_by_tag :tag=>"foo", :limit=>-1}.should raise_error(ArgumentError)
      lambda{@api.get_slideshows_by_tag :tag=>"foo", :limit=>"2asdf"}.should raise_error(ArgumentError)
    end

    it "should raise an error if :offset is not a positive integer" do
      lambda{@api.get_slideshows_by_tag :tag=>"foo", :offset=>0}.should raise_error(ArgumentError)
      lambda{@api.get_slideshows_by_tag :tag=>"foo", :offset=>-1}.should raise_error(ArgumentError)
      lambda{@api.get_slideshows_by_tag :tag=>"foo", :offset=>"2asdf"}.should raise_error(ArgumentError)
    end


    it "should retrieve detailed content when requested" do
      response=@api.get_slideshows_by_tag(:tag=>"business", :detailed=>true)
      response.should_not be_nil
      response.should be_a_kind_of GetSlideshowsByTagResponse
      response.slideshows.should_not be_empty
    end
  end

end


