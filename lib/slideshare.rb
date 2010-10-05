require 'util'

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
    # Required arguments
    #
    #    slideshow_id  => id of the slideshow to be fetched.
    #    slideshow_url => URL of the slideshow to be fetched. This is required if slideshow_id is not set. If both are set, slideshow_id takes precedence.
    #
    # Optional arguments
    #
    #    :username => username of the requesting user
    #    :password => password of the requesting user
    #    :exclude_tags => Exclude tags from the detailed information. true to exclude.
    #    :detailed => Whether or not to include optional information. true to include, false (default) for basic information.              
    def get_slideshow(slideshow_id, slideshow_url, args={})
    
    end
  
  end

end