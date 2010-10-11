require 'slideshare'
require 'configuration'

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
      response=@api.get_slideshows_by_tag(:tag=>"art", :detailed=>true)
      response.should_not be_nil
      response.should be_a_kind_of GetSlideshowsByTagResponse
      response.slideshows.should_not be_empty
    end
  end


  describe "get_user_groups" do
    before(:each) do
      @api=API.new Config::API_KEY, Config::SHARED_SECRET, :proxy_host=>Config::PROXY_HOST, :proxy_port=>Config::PROXY_PORT
    end

    it "should raise an error if :user is not provided" do
      lambda{@api.get_user_groups}.should raise_error(ArgumentError)
    end

    it "should raise an error  if :username_for is not a string" do
      lambda{@api.get_user_groups :username_for=>3}.should raise_error(ArgumentError)
      lambda{@api.get_user_groups :username_for=>nil}.should raise_error(ArgumentError)
    end

    it "should raise an error  if :username provided, but :password not" do
      lambda{@api.get_user_groups :username_for=>"user", :username=>"username"}.should raise_error(ArgumentError)
    end

    it "should ignore :password  if :password provided, but :username not" do
      lambda{@api.get_user_groups :username_for=>"user", :password=>"password"}.should_not raise_error(ArgumentError)
    end

    it "should retrieve detailed content when requested" do
      response=@api.get_user_groups(:username_for=>"Bern7")
      response.should_not be_nil
      response.should be_a_kind_of Array
      response.should_not be_empty
    end

  end

  describe "get_slideshows_by_group" do
    before(:each) do
      @api=API.new Config::API_KEY, Config::SHARED_SECRET, :proxy_host=>Config::PROXY_HOST, :proxy_port=>Config::PROXY_PORT
    end

    it "should raise an error if :group_name is not provided" do
      lambda{@api.get_slideshows_by_group}.should raise_error(ArgumentError)
    end

    it "should raise an error  if :group_name is not a string" do
      lambda{@api.get_slideshows_by_group :group_name=>3}.should raise_error(ArgumentError)
      lambda{@api.get_slideshows_by_group :group_name=>nil}.should raise_error(ArgumentError)
    end


    it "should raise an error if :detailed is neither true nor false" do
      lambda{@api.get_slideshows_by_group :group_name=>"foo", :detailed=>1}.should raise_error(ArgumentError)
    end

    it "should raise an error if :limit is not a positive integer" do
      lambda{@api.get_slideshows_by_group :group_name=>"foo", :limit=>0}.should raise_error(ArgumentError)
      lambda{@api.get_slideshows_by_group :group_name=>"foo", :limit=>-1}.should raise_error(ArgumentError)
      lambda{@api.get_slideshows_by_group :group_name=>"foo", :limit=>"2asdf"}.should raise_error(ArgumentError)
    end

    it "should raise an error if :offset is not a positive integer" do
      lambda{@api.get_slideshows_by_group :group_name=>"foo", :offset=>0}.should raise_error(ArgumentError)
      lambda{@api.get_slideshows_by_group :group_name=>"foo", :offset=>-1}.should raise_error(ArgumentError)
      lambda{@api.get_slideshows_by_group :group_name=>"foo", :offset=>"2asdf"}.should raise_error(ArgumentError)
    end


    it "should retrieve detailed content when requested" do
      response=@api.get_slideshows_by_group(:group_name=>"art", :detailed=>true)
      response.should_not be_nil
      response.should be_a_kind_of GetSlideshowsByGroupResponse
      response.slideshows.should_not be_empty
      response.group_searched.should == "art"
    end
  end

  describe "get_slideshows_by_user" do
    before(:each) do
      @api=API.new Config::API_KEY, Config::SHARED_SECRET, :proxy_host=>Config::PROXY_HOST, :proxy_port=>Config::PROXY_PORT
    end

    it "should raise an error if :username_for is not provided" do
      lambda{@api.get_slideshows_by_user}.should raise_error(ArgumentError)
    end

    it "should raise an error  if :username_for is not a string" do
      lambda{@api.get_slideshows_by_user :username_for=>3}.should raise_error(ArgumentError)
      lambda{@api.get_slideshows_by_user :username_for=>nil}.should raise_error(ArgumentError)
    end


    it "should raise an error if :detailed is neither true nor false" do
      lambda{@api.get_slideshows_by_user :username_for=>"foo", :detailed=>1}.should raise_error(ArgumentError)
    end

    it "should raise an error if :limit is not a positive integer" do
      lambda{@api.get_slideshows_by_user :username_for=>"foo", :limit=>0}.should raise_error(ArgumentError)
      lambda{@api.get_slideshows_by_user :username_for=>"foo", :limit=>-1}.should raise_error(ArgumentError)
      lambda{@api.get_slideshows_by_user :username_for=>"foo", :limit=>"2asdf"}.should raise_error(ArgumentError)
    end

    it "should raise an error if :offset is not a positive integer" do
      lambda{@api.get_slideshows_by_user :username_for=>"foo", :offset=>0}.should raise_error(ArgumentError)
      lambda{@api.get_slideshows_by_user :username_for=>"foo", :offset=>-1}.should raise_error(ArgumentError)
      lambda{@api.get_slideshows_by_user :username_for=>"foo", :offset=>"2asdf"}.should raise_error(ArgumentError)
    end


    it "should retrieve detailed content when requested" do
      response=@api.get_slideshows_by_user(:username_for=>"miguelff", :detailed=>true)
      response.should_not be_nil
      response.should be_a_kind_of GetSlideshowsByUserResponse
      response.slideshows.should_not be_empty
      response.user_searched.should == "miguelff"
    end
  end

  describe "search_slideshows" do
    before(:each) do
      @api=API.new Config::API_KEY, Config::SHARED_SECRET, :proxy_host=>Config::PROXY_HOST, :proxy_port=>Config::PROXY_PORT
    end

    it "should raise an error if no arguments provided" do
      lambda{@api.search_slideshows}.should raise_error(ArgumentError)
    end

    it "should raise an error if :q is not provided" do
      lambda{@api.search_slideshows :t=>nil}.should raise_error(ArgumentError)
    end
    
    it "should raise an error if :q is not a string" do
      lambda{@api.search_slideshows :q=>nil}.should raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>3}.should raise_error(ArgumentError)
    end

    it "should raise an error if :page is not a positive_integer" do
      lambda{@api.search_slideshows :q=>"art", :page=>-1}.should raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :page=>0}.should raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :page=>"wrong"}.should raise_error(ArgumentError)
    end

    it "should not raise an error if :page is a positive_integer" do
      lambda{@api.search_slideshows :q=>"art", :page=>1}.should_not raise_error(ArgumentError)
    end

    it "should raise an error if items_per_page is not a positive integer" do
      lambda{@api.search_slideshows :q=>"art", :items_per_page=>-1}.should raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :items_per_page=>0}.should raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :items_per_page=>"wrong"}.should raise_error(ArgumentError)
    end

    it "should not raise an error if :items_per_page is a positive_integer" do
      lambda{@api.search_slideshows :q=>"art", :items_per_page=>1}.should_not raise_error(ArgumentError)
    end

    it "should raise an error if :lang is not a valid language code" do
      lambda{@api.search_slideshows :q=>"art", :lang=>"en"}.should raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :lang=>:foo}.should raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :lang=>nil}.should raise_error(ArgumentError)
    end

    it "should not raise an error if :lang is a valid language code" do
      lambda{@api.search_slideshows :q=>"art", :lang=>:en}.should_not raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :lang=>:"**"}.should_not raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :lang=>:"!!"}.should_not raise_error(ArgumentError)
    end

    it "should raise an error if :sort is not a valid sort order" do
      lambda{@api.search_slideshows :q=>"art", :sort=>"relevance"}.should raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :sort=>:foo}.should raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :sort=>nil}.should raise_error(ArgumentError)
    end

    it "should not raise an error if :sort is a valid sort order" do
      lambda{@api.search_slideshows :q=>"art", :sort=>:relevance}.should_not raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :sort=>:mostviewed}.should_not raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :sort=>:mostdownloaded}.should_not raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :sort=>:latest}.should_not raise_error(ArgumentError)
    end

    it "should raise an error if :upload_date is not a valid upload date" do
      lambda{@api.search_slideshows :q=>"art", :upload_date=>"week"}.should raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :upload_date=>:foo}.should raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :upload_date=>nil}.should raise_error(ArgumentError)
    end

    it "should not raise an error if :upload_date is a valid upload date" do
      lambda{@api.search_slideshows :q=>"art", :upload_date=>:any}.should_not raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :upload_date=>:week}.should_not raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :upload_date=>:month}.should_not raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :upload_date=>:year}.should_not raise_error(ArgumentError)
    end

    it "should raise an error if :search_in_tags_only is not true or false" do
      lambda{@api.search_slideshows :q=>"art", :search_in_tags_only=>:foo}.should raise_error(ArgumentError)
    end

    it "should not raise an error if :search_in_tags_only is true or false" do
      lambda{@api.search_slideshows :q=>"art", :search_in_tags_only=>true}.should_not raise_error(ArgumentError)
    end

    it "should raise an error if :restrict_to_downloadables is not true or false" do
      lambda{@api.search_slideshows :q=>"art", :restrict_to_downloadables=>:foo}.should raise_error(ArgumentError)
    end

    it "should not raise an error if :restrict_to_downloadables is true or false" do
      lambda{@api.search_slideshows :q=>"art", :restrict_to_downloadables=>true}.should_not raise_error(ArgumentError)
    end

    it "should raise an error if :file_format is not a valid file format" do
      lambda{@api.search_slideshows :q=>"art", :file_format=>"pdf"}.should raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :file_format=>:foo}.should raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :file_format=>nil}.should raise_error(ArgumentError)
    end

    it "should not raise an error if :file_format is a valid file format" do
      lambda{@api.search_slideshows :q=>"art", :file_format=>:all}.should_not raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :file_format=>:pdf}.should_not raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :file_format=>:ppt}.should_not raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :file_format=>:odp}.should_not raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :file_format=>:pps}.should_not raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :file_format=>:pot}.should_not raise_error(ArgumentError)
    end

    it "should raise an error if :file_type is not a valid file type" do
      lambda{@api.search_slideshows :q=>"art", :file_type=>"presentation"}.should raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :file_type=>:foo}.should raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :file_type=>nil}.should raise_error(ArgumentError)
    end

    it "should not raise an error if :file_type is a valid file type" do
      lambda{@api.search_slideshows :q=>"art", :file_type=>:all}.should_not raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :file_type=>:presentations}.should_not raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :file_type=>:documents}.should_not raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :file_type=>:webinars}.should_not raise_error(ArgumentError)
      lambda{@api.search_slideshows :q=>"art", :file_type=>:videos}.should_not raise_error(ArgumentError)
    end

    it "should raise an error if :restrict_to_cc is not true or false" do
      lambda{@api.search_slideshows :q=>"art", :restrict_to_cc=>:foo}.should raise_error(ArgumentError)
    end

    it "should not raise an error if :restrict_to_cc is true or false" do
      lambda{@api.search_slideshows :q=>"art", :restrict_to_cc=>true}.should_not raise_error(ArgumentError)
    end

    it "should raise an error if :restrict_to_cc_adapt is not true or false" do
      lambda{@api.search_slideshows :q=>"art", :restrict_to_cc_adapt=>:foo}.should raise_error(ArgumentError)
    end

    it "should not raise an error if :restrict_to_cc_adapt is true or false" do
      lambda{@api.search_slideshows :q=>"art", :restrict_to_cc_adapt=>true}.should_not raise_error(ArgumentError)
    end
    
    it "should raise an error if :restrict_to_cc_commercial is not true or false" do
      lambda{@api.search_slideshows :q=>"art", :restrict_to_cc_commercial=>:foo}.should raise_error(ArgumentError)
    end

    it "should not raise an error if :restrict_to_cc_commercial is true or false" do
      lambda{@api.search_slideshows :q=>"art", :restrict_to_cc_commercial=>true}.should_not raise_error(ArgumentError)
    end

    it "should raise an error if :detailed is not true or false" do
      lambda{@api.search_slideshows :q=>"art", :detailed=>:foo}.should raise_error(ArgumentError)
    end

    it "should not raise an error if :detailed is true or false" do
      lambda{@api.search_slideshows :q=>"art", :detailed=>true}.should_not raise_error(ArgumentError)
    end

    it "should complete the request without giving any error" do
      search_results = @api.search_slideshows :q => "art",
        :page => 1,
        :items_per_page => 12,
        :lang =>:"**",
        :sort =>:mostviewed,
        :upload_date=>:any,
        :search_in_tags_only => true,
        :restrict_to_downloadables=>true,
        :file_format=>:ppt,
        :file_type=>:presentations,
        :restrict_to_cc => true,
        :restrict_to_cc_adapt => true,
        :restrict_to_cc_commercial => true,
        :detailed => false

      search_results.should_not be_nil
      search_results.items.should be_kind_of Array
      search_results.items.should_not be_empty
      search_results.query.should be_kind_of String
      search_results.total_number_of_results.should > 0
      search_results.result_offset.should > 0
    end

    it "a more restrictive request should retrieve less results then other less restrictive" do
      less_restrictive = @api.search_slideshows :q => "art"
      more_restrictive = @api.search_slideshows :q => "art",
        :page => 1,
        :items_per_page => 12,
        :lang =>:"**",
        :sort =>:mostviewed,
        :upload_date=>:any,
        :search_in_tags_only => true,
        :restrict_to_downloadables=>true,
        :file_format=>:ppt,
        :file_type=>:presentations,
        :restrict_to_cc => true,
        :restrict_to_cc_adapt => true,
        :restrict_to_cc_commercial => true,
        :detailed => false
      less_restrictive.total_number_of_results.should > more_restrictive.total_number_of_results
    end
    
  end

  describe "get_user_contacts" do
    before(:each) do
      @api=API.new Config::API_KEY, Config::SHARED_SECRET, :proxy_host=>Config::PROXY_HOST, :proxy_port=>Config::PROXY_PORT
    end

    it "should raise an error if :user is not provided" do
      lambda{@api.get_user_contacts}.should raise_error(ArgumentError)
    end

    it "should raise an error  if :username_for is not a string" do
      lambda{@api.get_user_contacts :username_for=>3}.should raise_error(ArgumentError)
      lambda{@api.get_user_contacts :username_for=>nil}.should raise_error(ArgumentError)
    end

    it "should raise an error if :limit is not a positive integer" do
      lambda{@api.get_slideshows_by_tag :username_for=>"user", :limit=>0}.should raise_error(ArgumentError)
      lambda{@api.get_slideshows_by_tag :username_for=>"user", :limit=>-1}.should raise_error(ArgumentError)
      lambda{@api.get_slideshows_by_tag :username_for=>"user", :limit=>"2asdf"}.should raise_error(ArgumentError)
    end

    it "should raise an error if :offset is not a positive integer" do
      lambda{@api.get_slideshows_by_tag :username_for=>"user", :offset=>0}.should raise_error(ArgumentError)
      lambda{@api.get_slideshows_by_tag :username_for=>"user", :offset=>-1}.should raise_error(ArgumentError)
      lambda{@api.get_slideshows_by_tag :username_for=>"user", :offset=>"2asdf"}.should raise_error(ArgumentError)
    end


    it "should retrieve the list of contacts  when requested" do
      response=@api.get_user_contacts(:username_for=>"Bern7", :offset=>1, :limit=>100)
      response.should_not be_nil
      response.should be_a_kind_of Array
      response.should_not be_empty
    end

  end

  describe "get_user_tags" do
    before(:each) do
      @api=API.new Config::API_KEY, Config::SHARED_SECRET, :proxy_host=>Config::PROXY_HOST, :proxy_port=>Config::PROXY_PORT
    end

    it "should raise an error if :username is not provided" do
      lambda{@api.get_user_tags}.should raise_error(ArgumentError)
    end

    it "should raise an error  if :username is provided but :password not" do
      lambda{@api.get_user_tags :username=>"foo"}.should raise_error(ArgumentError)
    end

    it "should raise an error  if :password is provided but :username not" do
      lambda{@api.get_user_tags :password=>"foo"}.should raise_error(ArgumentError)
    end


    it "should retrieve the list of tags when requested" do
      response=@api.get_user_tags(:username => Config::SAMPLE_USERNAME, :password => Config::SAMPLE_PASSWORD)
      response.should_not be_nil
      response.should be_a_kind_of Array
      response.should_not be_empty
      lambda{response.first.times_used}.should_not raise_error
      lambda{response.first.used_by_owner}.should raise_error
    end
  end
  
end


