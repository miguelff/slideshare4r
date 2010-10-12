$:.unshift File.join(File.dirname(__FILE__),'..')
require 'slideshare'
require 'configuration'

include Slideshare

describe "API#get_slideshows_by_tag" do
  before(:each) do
    @api=API.new Config::API_KEY, Config::SHARED_SECRET, :proxy_host=>Config::PROXY_HOST, :proxy_port=>Config::PROXY_PORT, :protocol=>:http
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
