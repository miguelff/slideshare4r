$:.unshift File.join(File.dirname(__FILE__),'..')
require 'slideshare'
require 'configuration'

include Slideshare

describe "API#get_slideshow" do
  before(:each) do
    @api=API.new Config::API_KEY, Config::SHARED_SECRET, :proxy_host=>Config::PROXY_HOST, :proxy_port=>Config::PROXY_PORT, :protocol=>:http
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
