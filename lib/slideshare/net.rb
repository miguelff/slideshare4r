require 'cgi'
require 'net/http'
require 'uri'

module Slideshare
  
  #An error raised when a request
  #completes without success
  class HTTPError < StandardError
    attr_reader :response_class
    
    def initialize(response_class)
      @response_class=response_class
    end
    
    def to_s
      response_class.to_s
    end
  end
  
  # Adapts an API URL, providing a method to get its content.
  class URL
  
    attr_reader  :path,  :query, :complete_path, :params, :url
    alias :adaptee :url
  
    BASE_URL="http://www.slideshare.net/api/2/"
  
    # initializes a new slideshare url, appending the given path to the base API URL,
    # and if provided, an URL-encoded flavor of the given args
    def initialize(_path,args={})
      raise ArgumentError.new("path cannot be nil") if _path.nil?
      @path = _path.to_s
      @query = args.to_a.map{|i| escape(i[0])+"="+escape(i[1])}.join("&")
      @complete_path = path + (query.empty? ? "" : "?"+query)
      @params = args
      @url = URI.parse(BASE_URL+complete_path)
    end
  
    # Requests the document pointed by this URL
    #
    # optionally you can provide a proxy to perform the Request.
    def get(proxy=nil)
      net = (proxy.nil? ? Net::HTTP : proxy)
      res=net.get_response(url)
      raise HTTPError.new(res.class) unless res.kind_of? Net::HTTPSuccess
      res.body
    end

    def hash
      url.hash
    end
    
    def eql?(other)
      url.eql?(other.url)
    end
    
    def to_s
      url.to_s
    end
    
    private 
    def escape(s)
      CGI::escape(s.to_s)
    end
  end
  
   #adapts a Net::HTTP.Proxy class
   class Proxy

     attr_reader :host, :port, :user, :password, :proxy
     alias :adaptee :proxy

     # Initializes a new instance of an HTTP proxy
     #
     # [+host+] Proxy host (e.g. proxy.organization.com)
     # [+port+] An integer between 0 and 65535, defaults to 8080
     # [+user+] If it needs authentication, proxy's user name
     # [+password+] If it needs authentication, proxy's user password
     def initialize(host, port=8080, user=nil, password=nil)
       raise ArgumentError.new "you must provide host and port for the proxy. (Provided: host=>#{host}, port=>#{port})" if host.nil? || port.nil?
       raise ArgumentError.new "host must be a string and it's #{host}" unless host.kind_of? String
       raise ArgumentError.new "proxy port must be a number between 0 and 65535 and it's #{port}" unless (port.kind_of? Fixnum and port >= 0 and port <= 65535)
       raise ArgumentError.new "You must provide a password for the proxy user" if not user.nil? and password.nil?
       @host=host
       @port=port
       @user=user
       @password=password
       @proxy=Net::HTTP.Proxy(host,port,user,password)
     end

     #indicates wether this proxy uses authentiation or not
     def uses_authentication?
       not user.nil?
     end 

     #tries to delagate unhandled requests to de proxy instance adapted
     def method_missing(method,*args,&b)
      if proxy.respond_to? method
        proxy.method(method).call(*args,&b)
      else
        super.method_missing(method, *args,&b)
      end
     end

     def hash
       host.hash
     end
     
     def eql?(other)
       host.eql?(other.host) and port.eql?(other.port) and user.eql?(other.user) and password.eql?(other.password)
     end
     
     def to_s
       "#{user}@#{host}:#{port}"
     end
   end
   
end

