require 'cgi'
require 'open-uri'
require 'uri'
require 'slideshare/model'

module Slideshare
  

  # Adapts an API URL, providing a method to get its content.
  class URL
  
    attr_reader  :protocol, :method, :get_parameters, :complete_path, :query, :url
    alias :adaptee :url
  
    BASE_URL="www.slideshare.net/api/2/"
  
    # Initializes a new webservice url
    #
    # [+method+] The webmethod to invoke.
    # [+protocol+] Protocol to use, must be :http or :https
    # [+args+] A set of the arguments for the URL. (GET parameters)
    #
    def initialize(method,protocol=:https,get_parameters={})
      raise ArgumentError.new("method cannot be nil") if method.nil?
      raise ArgumentError.new("protocol must be either :https or :http and it's #{protocol}") unless [:http,:https].member? protocol
      @protocol = protocol
      @method = method.to_s
      @query = get_parameters.to_a.map{|i| escape(i[0])+"="+escape(i[1])}.join("&")
      @complete_path = method.to_s + (query.empty? ? "" : "?"+query)
      @get_parameters = get_parameters
      @url = URI.parse("#{protocol}://#{BASE_URL}#{complete_path}")
    end
  
    # Requests the content pointed by this URL
    #
    # optionally you can provide an instance of Slideshare::Proxy to perform the request
    #
    # returns the content pointed by this url
    #
    # raise Slideshare::ServiceError if an error related to the service occurs
    # (wrong authorization, a required argument is missing...)
    def get(proxy=nil)
      proxy = proxy.nil? ? nil : proxy.to_s
      result=open(url,:proxy=>proxy).read
      raise ServiceError.from_xml result if result =~ /SlideShareServiceError/
      result
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
       credentials=""
       credentials << "#{user}:#{password}@" if user and password
       return "http://#{credentials}#{host}:#{port}"
     end
   end
   
end

