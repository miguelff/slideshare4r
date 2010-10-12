$:.unshift File.join(File.dirname(__FILE__),'..')
require 'uri'
require 'slideshare/model'
require 'slideshare/net'
require 'configuration'

include Slideshare

describe URL do
  
  it "should compose a correct URL when only a path is provided" do
    URL.new("path").url.should eql(URI.parse "https://www.slideshare.net/api/2/path")
    URL.new(3).url.should eql(URI.parse "https://www.slideshare.net/api/2/3")
  end
  
  # it "should compose a correct URL when path and args are provided" do
  #    URL.new("path",:a=>1, :b=>2).url.should eql(URI.parse("http://www.slideshare.net/api/2/path?a=1&b=2"))
  #  end
  
  it "should fail to build a correct URL if no path is provided" do
    lambda{URL.new(nil)}.should raise_error(ArgumentError)
  end
  
  it "should not take care of parameters order" do
    URL.new("path",:http,:a=>1, :b=>2).should eql(URL.new("path",:http,:b=>2,:a=>1))
  end
   
  it "should retrieve content when get is performed against a valid URL" do
    api_url=URL.new("path",:http)
    #we hack the url to test fetching functionality
    def api_url.url
      URI.parse("http://www.w3.org/robots.txt")
    end
    (api_url.get(Proxy.new Config::PROXY_HOST,Config::PROXY_PORT).should_not be_nil) unless Config::PROXY_HOST.empty?
    (api_url.get.should_not be_nil) if Config::PROXY_HOST.empty?
  end
   
  it "should failed retrieving content when get is performed against a wrong URL" do
    api_url=URL.new("path")
    #we hack the url to test fetching functionality
    def api_url.url
      URI.parse("http://xxxxxxxxxxxxxxx.xxx/")
    end
    (lambda{api_url.get(Proxy.new Config::PROXY_HOST,Config::PROXY_PORT)}.should raise_error) unless Config::PROXY_HOST.empty?
    (lambda{api_url.get}.should raise_error) if Config::PROXY_HOST.empty?
  end

  it "should failed retrieving content when get is performed against an HTTPS URL without using a proxy" do
    api_url=URL.new("path")
    #we hack the url to test fetching functionality
    def api_url.url
      URI.parse("https://msp.f-secure.com/web-test/common/test.html")
    end
    lambda{api_url.get}.should_not raise_error
  end

   it "should raise a Service error when requesting an API URL that's not correct" do
    api_url=URL.new("path")
    #we hack the url to test fetching functionality
    def api_url.url
      URI.parse("http://www.slideshare.net/api/2/get_slideshow")
    end
    lambda{api_url.get}.should raise_error(ServiceError)
  end
  
end