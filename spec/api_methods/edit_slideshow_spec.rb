$:.unshift File.join(File.dirname(__FILE__),'..')
require 'slideshare'
require 'configuration'

include Slideshare

describe "API#edit_slideshow" do
  before(:each) do
    @api=API.new Config::API_KEY, Config::SHARED_SECRET, :proxy_host=>Config::PROXY_HOST, :proxy_port=>Config::PROXY_PORT, :protocol=>:http
  end

  it "should raise an argument error if any of :username, :password, :slideshow_id is not provided" do
    lambda{@api.edit_slideshow :password=>"bar", :slideshow_id=>"baz"}.should raise_error ArgumentError
    lambda{@api.edit_slideshow :username=>"foo", :slideshow_id=>"baz"}.should raise_error ArgumentError
    lambda{@api.edit_slideshow :username=>"foo", :password=>"bar"}.should raise_error ArgumentError
  end

  it "should raise an argument error if any of :username, :password, :slideshow_id are not strings" do
    lambda{@api.edit_slideshow :username=>1,:password=>"bar", :slideshow_id=>"baz"}.should raise_error ArgumentError
    lambda{@api.edit_slideshow :username=>"foo",:password=>1, :slideshow_id=>"baz"}.should raise_error ArgumentError
    lambda{@api.edit_slideshow :username=>"foo",:password=>"bar", :slideshow_id=>1}.should raise_error ArgumentError
  end

  it "should not raise an argument error if all of :username, :password, :slideshow_id are provided" do
   lambda{@api.edit_slideshow :username=>"foo",:password=>"bar", :slideshow_id=>"baz"}.should_not raise_error ArgumentError
  end

  it "should raise an argument error if any of :generate_secret_url, :allow_embeds, :share_with_contacts are provided but :make_private not" do
   lambda{@api.edit_slideshow :username=>"foo",:password=>"bar", :slideshow_id=>"baz", :generate_secret_url=>true}.should raise_error ArgumentError
   lambda{@api.edit_slideshow :username=>"foo",:password=>"bar", :slideshow_id=>"baz", :allow_embeds=>true}.should raise_error ArgumentError
   lambda{@api.edit_slideshow :username=>"foo",:password=>"bar", :slideshow_id=>"baz", :share_with_contacts=>true}.should raise_error ArgumentError
  end

  it "should raise an argument error if any of :generate_secret_url, :allow_embeds, :share_with_contacts is not true or false" do
   lambda{@api.edit_slideshow :username=>"foo",:password=>"bar", :slideshow_id=>"baz", :make_private=>true, :generate_secret_url=>"Y"}.should raise_error ArgumentError
   lambda{@api.edit_slideshow :username=>"foo",:password=>"bar", :slideshow_id=>"baz", :make_private=>true, :allow_embeds=>"Y"}.should raise_error ArgumentError
   lambda{@api.edit_slideshow :username=>"foo",:password=>"bar", :slideshow_id=>"baz", :make_private=>true, :share_with_contacts=>3}.should raise_error ArgumentError
  end

  it "should not raise an argument error if any of :generate_secret_url, :allow_embeds, :share_with_contacts is true or false" do
   lambda{@api.edit_slideshow :username=>"foo",:password=>"bar", :slideshow_id=>"baz", :make_private=>true, :generate_secret_url=>true}.should_not raise_error ArgumentError
   lambda{@api.edit_slideshow :username=>"foo",:password=>"bar", :slideshow_id=>"baz", :make_private=>true, :allow_embeds=>true}.should_not raise_error ArgumentError
   lambda{@api.edit_slideshow :username=>"foo",:password=>"bar", :slideshow_id=>"baz", :make_private=>true, :share_with_contacts=>true}.should_not raise_error ArgumentError
   lambda{@api.edit_slideshow :username=>"foo",:password=>"bar", :slideshow_id=>"baz", :make_private=>true, :generate_secret_url=>false}.should_not raise_error ArgumentError
   lambda{@api.edit_slideshow :username=>"foo",:password=>"bar", :slideshow_id=>"baz", :make_private=>true, :allow_embeds=>false}.should_not raise_error ArgumentError
   lambda{@api.edit_slideshow :username=>"foo",:password=>"bar", :slideshow_id=>"baz", :make_private=>true, :share_with_contacts=>false}.should_not raise_error ArgumentError
  end

  it "should raise an error if :title is not a string" do
   lambda{@api.edit_slideshow :username=>"foo",:password=>"bar", :slideshow_id=>"baz", :title=>3}.should raise_error ArgumentError
  end

  it "should not raise an error if :title is a string" do
   lambda{@api.edit_slideshow :username=>"foo",:password=>"bar", :slideshow_id=>"baz", :title=>"title"}.should_not raise_error ArgumentError
  end

  it "should raise an error if :description is not a string" do
   lambda{@api.edit_slideshow :username=>"foo",:password=>"bar", :slideshow_id=>"baz", :description=>3}.should raise_error ArgumentError
  end

  it "should not raise an error if :description is a string" do
   lambda{@api.edit_slideshow :username=>"foo",:password=>"bar", :slideshow_id=>"baz", :description=>"title"}.should_not raise_error ArgumentError
  end

  it "should raise an error if :tags is not a list" do
   lambda{@api.edit_slideshow :username=>"foo",:password=>"bar", :slideshow_id=>"baz", :tags=>"tags tags tags"}.should raise_error ArgumentError
  end

  it "should not raise an error if :tags is a list" do
   lambda{@api.edit_slideshow :username=>"foo",:password=>"bar", :slideshow_id=>"baz", :tags=>"tags tags tags".split(" ")}.should_not raise_error ArgumentError
  end

  # although this is a unit test and should not depend
  # on other functionality, we will use other API services
  # to make this test independent from any slideshare user.
  # It's enough that the user has one public slideshow for
  # this method to work
  # (remember the user creentials are provided in configuration.rb)
  #
  # This method retrieves the first non-private slideshow for the user whose
  # credentials are defined in the configuration file. Than it modifies it
  # and retrieves it again, asserting that the values modified are different from
  # the original ones. After all, the slideshow is again edited back to its original
  # state, asserting that its state is the same as when retrieved the first time.
  #
  it "should edit an existing slideshow" do
    sample_slideshow=@api.get_slideshows_by_user(:username_for=>Config::SAMPLE_USERNAME, :detailed=>true).reject{|ss| ss.is_private }.first
    
    slideshow_id=sample_slideshow.slideshow_id
    old_title=sample_slideshow.title
    old_description=sample_slideshow.description
    old_tags=sample_slideshow.tags.map{|tag| tag.name}
    old_is_private=sample_slideshow.is_private
    old_is_secret_url_enabled=sample_slideshow.is_secret_url_enabled
    old_is_embed_allowed=sample_slideshow.is_embed_allowed
    old_is_only_shared_with_contacts=sample_slideshow.is_only_shared_with_contacts

    @api.edit_slideshow(
      :username=>Config::SAMPLE_USERNAME,
      :password=>Config::SAMPLE_PASSWORD,
      :tags=>%w{hi there},
      :title=>old_title.upcase,
      :description=>old_description.upcase,
      :slideshow_id=>slideshow_id,
      :make_private=>true,
      :generate_secret_url=>true,
      :allow_embeds=>true,
      :share_with_contacts=>true
    ).should == true

    modified_slideshow=@api.get_slideshow :detailed=>true, :username=>Config::SAMPLE_USERNAME, :password=>Config::SAMPLE_PASSWORD, :slideshow_id  => slideshow_id

    modified_slideshow.title.should_not == old_title
    modified_slideshow.description.should_not == old_description
    modified_slideshow.tags.member?(old_tags.first ||= "x").should == false
    modified_slideshow.is_private.should == !old_is_private
    modified_slideshow.is_secret_url_enabled.should == !old_is_secret_url_enabled
    modified_slideshow.is_embed_allowed.should == !old_is_embed_allowed
    modified_slideshow.is_only_shared_with_contacts.should == !old_is_only_shared_with_contacts

    @api.edit_slideshow(
      :username=>Config::SAMPLE_USERNAME,
      :password=>Config::SAMPLE_PASSWORD,
      :tags=>old_tags,
      :title=>old_title,
      :description=>old_description,
      :slideshow_id=>slideshow_id,
      :make_private=>old_is_private
    ).should == true

    modified_slideshow=@api.get_slideshow  :detailed=>true, :username=>Config::SAMPLE_USERNAME, :password=>Config::SAMPLE_PASSWORD, :slideshow_id  => slideshow_id

    modified_slideshow.title.should == old_title
    modified_slideshow.tags.map{|tag| tag.name}.should == old_tags
    modified_slideshow.is_private.should == old_is_private
    modified_slideshow.is_secret_url_enabled.should == old_is_secret_url_enabled
    modified_slideshow.is_embed_allowed.should == old_is_embed_allowed
    modified_slideshow.is_only_shared_with_contacts.should == old_is_only_shared_with_contacts
  end


end
