require 'cgi'

module Slideshare
  
  # Encapsulate an API URL, providing a method to get its content.
  class URL
  
    attr_reader :url
  
    BASE_URL="http://www.slideshare.net/api/2/"
  
    # initializes a new slideshare url, appending the given path to the base API URL,
    # and if provided, an URL-encoded flavor of the given args
    def initialize(path,args={})
      raise ArgumentError.new("path cannot be nil") if path.nil?
      partial_url=BASE_URL+path.to_s
      @url= partial_url + ( args.empty? ? "" : "?"+args.to_a.map{|i| escape(i[0])+"="+escape(i[1])}.join("&") )
    end
  
  
    # Requests the document pointed by this URL
    #
    # optionally you can provide a proxy to perform the Request.
    def get(proxy=nil)
      #raise ArgumentError.new "" unless proxy.nil? || proxy.kind_of? Proxy
      #TODO: implementar
    end

    private 
    def escape(s)
      CGI::escape(s.to_s)
    end
    
    def hash
      url.hash
    end
    
    def eql?(other)
      url.eql? other.url
    end
    
    def to_s
      url
    end
    
    
    
  end
  
  # encapsulates an HTTP proxy
   class Proxy

     attr_reader :host, :port, :user, :password

     # Initializes a new instance of an HTTP proxy
     #
     # host => proxy host (e.g. proxy.organization.com)
     # port => an integer between 0 and 65535
     # user => if it needs authentication, proxy's user name
     # password => if it needs authentication, proxy's user password
     def initialize(host, port, user=nil, password=nil)
       raise AgumentError.new "you must provide host and port for the proxy. (Provided: host=>#{host}, port=>#{port})" if host.nil? || port.nil?
       raise ArgumentError.new "proxy port must be a number between 0 and 65535 and it's #{port}" unless (port.kind_of? Fixnum and port >= 0 and port <= 65535)
       raise ArgumentError.new "You must provide a password for the proxy user" if not user.nil? and password.nil?
       @host=host
       @port=port
       @user=user
       @password=password

     end

     #indicates wether this proxy uses authentiation or not
     def uses_authentication?
       not user.nil?
     end 
     
     def hash
       host.hash
     end
     
     def eql?(other)
       host.eql?(other.host) and port.eql?(other.port) and user.eql?(other.user) and password.eql?(other.password)
     end
     
     def to_s
       "#{user}:#{password}@#{host}:#{port}"
     end

   end

end
