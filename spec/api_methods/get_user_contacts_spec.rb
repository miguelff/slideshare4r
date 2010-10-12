$:.unshift File.join(File.dirname(__FILE__),'..')
require 'slideshare'
require 'configuration'

include Slideshare

describe "API#get_user_contacts" do
  before(:each) do
    @api=API.new Config::API_KEY, Config::SHARED_SECRET, :proxy_host=>Config::PROXY_HOST, :proxy_port=>Config::PROXY_PORT, :protocol=>:http
  end

  it "should raise an error if :user is not provided" do
    lambda{@api.get_user_contacts}.should raise_error(ArgumentError)
  end

  it "should raise an error  if :username_for is not a string" do
    lambda{@api.get_user_contacts :username_for=>3}.should raise_error(ArgumentError)
    lambda{@api.get_user_contacts :username_for=>nil}.should raise_error(ArgumentError)
  end

  it "should raise an error if :limit is not a positive integer" do
    lambda{@api.get_user_contacts :username_for=>"user", :limit=>0}.should raise_error(ArgumentError)
    lambda{@api.get_user_contacts :username_for=>"user", :limit=>-1}.should raise_error(ArgumentError)
    lambda{@api.get_user_contacts :username_for=>"user", :limit=>"2asdf"}.should raise_error(ArgumentError)
  end

  it "should raise an error if :offset is not a positive integer" do
    lambda{@api.get_user_contacts :username_for=>"user", :offset=>0}.should raise_error(ArgumentError)
    lambda{@api.get_user_contacts :username_for=>"user", :offset=>-1}.should raise_error(ArgumentError)
    lambda{@api.get_user_contacts :username_for=>"user", :offset=>"2asdf"}.should raise_error(ArgumentError)
  end


  it "should retrieve the list of contacts  when requested" do
    response=@api.get_user_contacts(:username_for=>"Bern7", :offset=>1, :limit=>100)
    response.should_not be_nil
    response.should be_a_kind_of ContactList
    response.should_not be_empty
  end

end
