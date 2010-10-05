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
    lambda{API.new nil,"xxx"}.should raise_error
    lambda{API.new "xxx",nil}.should raise_error
    lambda{API.new nil,nil}.should raise_error
  end

   it "should failed initializitaion when neither api_key nor shared_secret is a string " do
    lambda{API.new "xxx",4}.should raise_error
    lambda{API.new 4,"xxx"}.should raise_error
    lambda{API.new 4,4}.should raise_error
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
    lambda{API.new "foo","bar",:proxy_host=>"proxy.foo.com",:proxy_port=>"wrong"}.should raise_error
    lambda{API.new "foo","bar",:proxy_host=>"proxy.foo.com",:proxy_port=>65536}.should raise_error
    lambda{API.new "foo","bar",:proxy_host=>"proxy.foo.com",:proxy_port=>-1}.should raise_error
    lambda{API.new "foo","bar",:proxy_host=>"proxy.foo.com",:proxy_port=>8888}.should_not raise_error
  end
end

