require 'digest/sha1'

require 'slideshare/net'
require 'slideshare/model'

module Slideshare

  #
  # API façade. Provides a single entry point to every API method.
  #
  class API

    attr_accessor :api_key, :shared_secret, :proxy

    # Initializes a new instance of the API Façade
    # 
    # You must provide your api key and its complemenetary shared secret in order to
    # validate the API calls. If you don't have an API key, you have to apply
    # for one at http://www.slideshare.net/developers/applyforapi
    #
    # Optionally you can provide some arguments:
    #
    # :proxy_host and :proxy_port => if you are connecting to slideshare behind and HTTP proxy
    # :proxy_user and :proxy_pass => if the proxy needs authentication
    #
    def initialize(api_key, shared_secret, args={})
      raise ArgumentError.new "api_key must be a String and it's #{api_key}" unless api_key.kind_of? String
      raise ArgumentError.new "shared_secret must be a String and it's #{shared_secret}" unless shared_secret.kind_of? String
      default_args={
        :username=>nil,
        :password=>nil,
        :proxy_host=>nil,
        :proxy_port=>nil,
        :proxy_user=>nil,
        :proxy_pass=>nil
      }
      args=default_args.merge args
      @api_key=api_key
      @shared_secret=shared_secret
 
      proxy_host=args[:proxy_host]
      proxy_port=args[:proxy_port]
      proxy_user=args[:proxy_user]
      proxy_pass=args[:proxy_pass]
    
      @proxy=Proxy.new(proxy_host,proxy_port,proxy_user,proxy_pass) unless proxy_host.nil?
    end
  
    #
    # Get Slideshow Information
    #
    # see http://www.slideshare.net/developers/documentation#get_slideshow for additional documentation
    #
    # Required arguments
    #    one of:
    #     slideshow_id  => id of the slideshow to be fetched.
    #     slideshow_url => URL of the slideshow to be fetched. This is required if slideshow_id is not set. If both are set, slideshow_id takes precedence.
    #
    # Optional arguments
    #
    #    :username => username of the requesting user
    #    :password => password of the requesting user
    #    :exclude_tags => Exclude tags from the detailed information. true to exclude.
    #    :detailed => Whether or not to include optional information. true to include, false (default) for basic information.
    #
    # => returns an Slideshare::Slideshow instance
    def get_slideshow(args={})
      default_args={
        :slideshow_id=>nil,
        :slideshow_url=>nil,
        :username=>nil,
        :password=>nil,
        :exclude_tags=>false,
        :detailed=>false,
      }
      
      args=default_args.merge args
      
      raise ArgumentError.new "One of slideshow_id or slideshow_url must be provided" if args[:slideshow_id].nil? and args[:slideshow_url].nil?
      raise ArgumentError.new ":exclude_tags must be true or false, but it's #{args[:exclude_tags]}" unless args[:exclude_tags]==true or args[:exclude_tags]==false
      raise ArgumentError.new ":detailed must be true or false, but it's #{args[:detailed]}" unless args[:detailed]==true or args[:detailed]==false
      raise ArgumentError.new ":password must be provided for :username=>#{args[:username]}" unless args[:username].nil? or not args[:password].nil?
      
      if args[:username].nil? 
            args.delete :username
            args.delete :password
      end
      
      args[:exclude_tags] = args[:exclude_tags] ? 1 : 0 
      args[:detailed] = args[:detailed] ? 1 : 0 
      
      discardable_identifier = args[:slideshow_id].nil? ? :slideshow_id : :slideshow_url 
      args.delete discardable_identifier
      
      response=perform_request("get_slideshow",args)
      Slideshare::Slideshow.from_xml(response)
    end
    
    private

    #performs an HTTP request to the given webmethod using the given optional args
    def perform_request(web_method,args={})
      ts=Time.now.to_i
      hash=Digest::SHA1.hexdigest(shared_secret+ts.to_s)
      args.merge! :api_key=>api_key, :ts=>ts, :hash=>hash
      url=URL.new web_method, args
      url.get @proxy
    end
  
  end

end
