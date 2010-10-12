$:.unshift File.join(File.dirname(__FILE__),'..')
require 'slideshare'
require 'configuration'

include Slideshare

describe "API#get_slideshows_by_user" do
  before(:each) do
    @api=API.new Config::API_KEY, Config::SHARED_SECRET, :proxy_host=>Config::PROXY_HOST, :proxy_port=>Config::PROXY_PORT, :protocol=>:http
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