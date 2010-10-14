require 'cgi'
require 'rest-open-uri'
require 'uri'
require 'tempfile'
require 'stringio'
require 'mime/types'

require 'slideshare/model'

module Slideshare
  

  # Models an API Request
  class Request
  
    attr_reader  :protocol, :method, :params, :url
    alias :adaptee :url
  
    BASE_URL="www.slideshare.net/api/2/"
    EOL="\r\n"
  
    # Initializes a new webservice url
    #
    # [+method+] The webmethod to invoke.
    # [+protocol+] Protocol to use, must be :http or :https
    # [+params+] A set of the arguments for the URL.
    #
    def initialize(method,protocol=:https,params={})
      raise ArgumentError.new("method cannot be nil") if method.nil?
      raise ArgumentError.new("protocol must be either :https or :http and it's #{protocol}") unless [:http,:https].member? protocol
      @protocol = protocol
      @method = method.to_s
      @params = params
      @boundary=rand(1_000_000).to_s
      @url = URI.parse("#{protocol}://#{BASE_URL}#{method}")
    end
  
    # Requests the content pointed by this request using the GET verb
    #
    # optionally you can provide an instance of Slideshare::Proxy to perform the request
    #
    # returns the content pointed by this url
    #
    # raise Slideshare::ServiceError if an error related to the service occurs
    # (wrong authorization, a required argument is missing...)
    def perform_get(proxy=nil)
      proxy = proxy.nil? ? nil : proxy.to_s
      result=open(url+build_query_string(params),:method=> :get, :proxy=>proxy).read
      raise StandardError.new ("result #{result.inspect}.") unless result.kind_of? String
      raise ServiceError.from_xml result if result =~ /SlideShareServiceError/
      result
    end

    # Posts to the service pointed by this URL the parameters encoded as multipart/form-data
    #
    # optionally you can provide an instance of Slideshare::Proxy to perform the request
    #
    # returns the response of the service as text
    #
    # raise Slideshare::ServiceError if an error related to the service occurs
    # (wrong authorization, a required argument is missing...)
    def perform_multipart_post(proxy=nil)
      proxy = proxy.nil? ? nil : proxy.to_s
      result=open(url,
        :method=> :post,
        :proxy=>proxy,
        :body => build_multipart_body(params),
        'Content-Type' => %Q{multipart/form-data; boundary=#{@boundary}}
      ).read
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
    
    def build_query_string(params)
      str=params.to_a.map{|i| escape(i[0])+"="+escape(i[1])}.join("&")
      str="?"+str unless str.empty?
      str
    end

    def build_multipart_body(params)
      separator="--#{@boundary}"
      stream = Tempfile.new("Slideshare.Uri.Stream.#{rand(1000)}")
      stream.binmode
      stream.write(separator + EOL)
      param_list=params.map do |key,value|
        if value.respond_to?(:read) && value.respond_to?(:path)
          create_file_part(stream, key, value)
        else
          create_regular_part(stream, key, value)
        end
      end
      (separator+EOL)+param_list.join(EOL+separator+EOL)+(EOL+separator+"--"+EOL)
      stream.seek(0)
      result=stream.read
      result.close(true)
      result
    end

    def create_regular_part(stream, key, value)
      stream.write("Content-Disposition: form-data; name=\"#{key}\"")
      stream.write(EOL)
      stream.write(EOL)
      stream.write(value)
    end

    def create_file_part(stream, key, file)
      begin
        stream.write("Content-Disposition: form-data;")
        stream.write(" name=\"#{key}\";") unless (key.nil? || key=='')
        stream.write(" filename=\"#{file.respond_to?(:original_filename) ? file.original_filename : File.basename(file.path)}\"#{EOL}")
        stream.write("Content-Type: #{file.respond_to?(:content_type) ? file.content_type : mime_for(file.path)}#{EOL}")
        stream.write(EOL)
        while data = file.read(8124)
          stream.write(data)
        end
      ensure
        file.close
      end
    end

    def mime_for(path)
      mime = MIME::Types.type_for path
      mime.empty? ? 'text/plain' : mime[0].content_type
    end

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

