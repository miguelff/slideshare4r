$:.unshift File.join(File.dirname(__FILE__),'..')
require 'slideshare'
require 'configuration'

include Slideshare

describe "API#get_user_tags" do
  before(:each) do
    @api=API.new Config::API_KEY, Config::SHARED_SECRET, :proxy_host=>Config::PROXY_HOST, :proxy_port=>Config::PROXY_PORT, :protocol=>:http
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
    response.should be_a_kind_of TagList
    response.should_not be_empty
    lambda{response.first.times_used}.should_not raise_error
    lambda{response.first.used_by_owner}.should raise_error
  end
end