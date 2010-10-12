$:.unshift File.join(File.dirname(__FILE__),'..')
require 'slideshare'
require 'configuration'

include Slideshare

describe "API#get_user_groups" do
    before(:each) do
      @api=API.new Config::API_KEY, Config::SHARED_SECRET, :proxy_host=>Config::PROXY_HOST, :proxy_port=>Config::PROXY_PORT, :protocol=>:http
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
