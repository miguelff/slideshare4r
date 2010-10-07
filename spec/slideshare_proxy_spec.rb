require 'slideshare/net'

include Slideshare

describe Proxy do
  
  it "should initialize when only proxy_host is provided" do
   p=Proxy.new "foo.bar.com"
   p.host.should eql("foo.bar.com")
   p.port.should eql(8080)
  end
  
  it "should fail initialization when proxy_host is not correct" do
    lambda{Proxy.new 0}.should raise_error(ArgumentError)
  end
  
  it "should initialize when a valid proxy_host and port are provided" do
    p=Proxy.new "foo.bar.com",8888
    p.host.should eql("foo.bar.com")
    p.port.should eql(8888)
  end

  it "should fail initialization when a wrong value for port is provided" do
    lambda{Proxy.new "foo.bar.com",123456}.should raise_error(ArgumentError)
    lambda{Proxy.new "foo.bar.com",nil}.should raise_error(ArgumentError)
  end
  
  it "should initialize when credentiales are provided" do
      p=Proxy.new "foo.bar.com",8888,"user","pass"
      p.host.should eql("foo.bar.com")
      p.port.should eql(8888)
      p.user.should eql("user")
      p.password.should eql("pass")
  end
  
  it "should fail initialization when username is provided but password is not" do
    lambda{Proxy.new "foo.bar.com",8888,"name"}.should raise_error(ArgumentError)
  end
  
  it "should return true when credentiales are provided and uses_authentication? is invoked" do
    p=Proxy.new "foo.bar.com",8888,"user","pass"
    p.uses_authentication?.should be_true
  end
  
  it "should return false when no credentiales are provided and uses_authentication? is invoked" do
    p=Proxy.new "foo.bar.com",8888
    p.uses_authentication?.should be_false
  end
  

end