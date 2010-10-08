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
    # Gets Slideshow Information
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
    # returns an Slideshare::Slideshow instance
    def get_slideshow(args={})
      usage=%q{
      Gets Slideshow Information

      see http://www.slideshare.net/developers/documentation#get_slideshow for additional documentation

      Required arguments
        one of:
         :slideshow_id  => id of the slideshow to be fetched.
         :slideshow_url => URL of the slideshow to be fetched. This is required if slideshow_id is not set. If both are set, slideshow_id takes precedence.

      Optional arguments

        :username => username of the requesting user
        :password => password of the requesting user
        :exclude_tags => Exclude tags from the detailed information. true to exclude.
        :detailed => Whether or not to include optional information. true to include, false (default) for basic information.

      returns an Slideshare::Slideshow instance
      }
      raise ArgumentError.new "No arguments provided. Usage:\n#{usage}" if args.empty?

      default_args={
        :slideshow_id=>nil,
        :slideshow_url=>nil,
        :username=>nil,
        :password=>nil,
        :exclude_tags=>false,
        :detailed=>false,
      }
      
      args=default_args.merge args
      args.reject!{|k,v| args[k].nil?}

      raise ArgumentError.new "One of :slideshow_id or :slideshow_url must be provided" if args[:slideshow_id].nil? and args[:slideshow_url].nil?
      raise ArgumentError.new ":exclude_tags must be true or false, but it's #{args[:exclude_tags]}" unless args[:exclude_tags]==true or args[:exclude_tags]==false
      raise ArgumentError.new ":password must be provided for :username=>#{args[:username]}" unless args[:username].nil? or not args[:password].nil?
      raise ArgumentError.new ":detailed must be true or false, but it's #{args[:detailed]}" unless args[:detailed]==true or args[:detailed]==false

      if args[:username].nil? 
        args.delete :password
      end
      args[:exclude_tags] = args[:exclude_tags] ? 1 : 0 
      args[:detailed] = args[:detailed] ? 1 : 0 
      
      response=perform_request("get_slideshow",args)
      Slideshare::Slideshow.from_xml(response)
    end

  
    # Get slideshows with a certain tag
    #
    # See http://www.slideshare.net/developers/documentation#get_slideshows_by_tag for additional documentation
    #
    # Required arguments
    #     :tag  => the tag name
    #   
    # Optional arguments
    #
    #    :limit => max number of items to return (defaults to 10)
    #    :offset => the number of slides to skip, before returning results.
    #    :detailed => Whether or not to include optional information. true to include, false (default) for basic information.
    #
    #  returns a GetSlideshowsByTagResponse instance
    def get_slideshows_by_tag(args={})
      usage=%q{
       Get slideshows with a certain tag

       See http://www.slideshare.net/developers/documentation#get_slideshows_by_tag for additional documentation

       Required arguments
          :tag  => the tag name

       Optional arguments

          :limit => max number of items to return (defaults to 10)
          :offset => the number of slides to skip, before returning results.
          :detailed => Whether or not to include optional information. true to include, false (default) for basic information.

       returns a GetSlideshowsByTagResponse instance
      }
      raise ArgumentError.new "No arguments provided. Usage:\n#{usage}" if args.empty?
      default_args={
        :tag =>nil,
        :limit =>10,
        :offset=>nil,
        :detailed=>false,
      }

      args=default_args.merge args
      args.reject!{|k,v| args[k].nil?}

      raise ArgumentError.new ":tag must be a string and it's #{args[:tag]}" unless args[:tag].kind_of? String
      raise ArgumentError.new ":limit must be a number greater than 0 and it's #{args[:limit]}" unless args[:limit].kind_of? Fixnum and args[:limit] > 0
      raise ArgumentError.new ":offset must be a number greater than 0 and it's #{args[:offset]}" unless args[:offset].nil? or (args[:offset].kind_of? Fixnum and args[:offset] > 0)
      raise ArgumentError.new ":detailed must be true or false, but it's #{args[:detailed]}" unless args[:detailed]==true or args[:detailed]==false

      args[:detailed] = args[:detailed] ? 1 : 0 

      response=perform_request("get_slideshows_by_tag",args)
      Slideshare::GetSlideshowsByTagResponse.from_xml(response)
    end

    # Gets the groups a user belongs to
    #
    # See http://www.slideshare.net/developers/documentation#get_slideshows_by_tag for additional documentation
    #
    # Required arguments
    #
    #    :username_for => name of user whose groups are being requested
    #
    # Optional arguments
    #
    #    :username => username of the requesting user
    #    :password => password of the requesting user
    #
    # returns a list of Group instances
    #
    def get_user_groups(args={})
      usage=%q{
         Gets the groups a user belongs to

         See http://www.slideshare.net/developers/documentation#get_slideshows_by_tag for additional documentation

         Required arguments

            :username_for => name of user whose groups are being requested

         Optional arguments

            :username => username of the requesting user
            :password => password of the requesting user

         returns a list of Group instances
      }
      raise ArgumentError.new "No arguments provided. Usage:\n#{usage}" if args.empty?

       default_args={
        :username_for =>nil,
        :username=>nil,
        :password=>nil,
      }

      args=default_args.merge args
      args.reject!{|k,v| args[k].nil?}

      raise ArgumentError.new ":username_for must be a string and it's #{args[:username_for]}" unless args[:username_for].kind_of? String
      raise ArgumentError.new ":password must be provided for :username=>#{args[:username]}" unless args[:username].nil? or not args[:password].nil?

      response=perform_request("get_user_groups",args)
      Slideshare::GroupList.from_xml(response).items
    end

    

    # Gets slideshows beonging to a certain user group.
    #
    # See http://www.slideshare.net/developers/documentation#get_slideshows_by_group for additional documentation
    #
    # Required arguments
    #     :group_name => Group name (as returned in :query_name in any of the elements returned by get_user_groups method)
    #
    # Optional arguments
    #
    #    :limit => max number of items to return (defaults to 10)
    #    :offset => the number of slides to skip, before returning results.
    #    :detailed => Whether or not to include optional information. true to include, false (default) for basic information.
    #
    # returns a GetSlideshowsByGroupResponse instance
    def get_slideshows_by_group(args={})
      usage=%q{
       Gets slideshows beonging to a certain user group.

       See http://www.slideshare.net/developers/documentation#get_slideshows_by_group for additional documentation

       Required arguments
           :group_name => Group name (as returned in :group_name element in get_user_groups method)

       Optional arguments

          :limit => max number of items to return (defaults to 10)
          :offset => the number of slides to skip, before returning results.
          :detailed => Whether or not to include optional information. true to include, false (default) for basic information.

       returns a GetSlideshowsByGroupResponse instance
      }
      raise ArgumentError.new "No arguments provided. Usage:\n#{usage}" if args.empty?
      default_args={
        :group_name =>nil,
        :limit =>10,
        :offset=>nil,
        :detailed=>false,
      }

      args=default_args.merge args
      args.reject!{|k,v| args[k].nil?}

      raise ArgumentError.new ":group_name must be a string and it's #{args[:group_name]}" unless args[:group_name].kind_of? String
      raise ArgumentError.new ":limit must be a number greater than 0 and it's #{args[:limit]}" unless args[:limit].kind_of? Fixnum and args[:limit] > 0
      raise ArgumentError.new ":offset must be a number greater than 0 and it's #{args[:offset]}" unless args[:offset].nil? or (args[:offset].kind_of? Fixnum and args[:offset] > 0)
      raise ArgumentError.new ":detailed must be true or false, but it's #{args[:detailed]}" unless args[:detailed]==true or args[:detailed]==false

      args[:detailed] = args[:detailed] ? 1 : 0

      response=perform_request("get_slideshows_by_group",args)
      Slideshare::GetSlideshowsByGroupResponse.from_xml(response)
    end
    
  private

  #performs an HTTP request to the given webmethod using the given optional args
  def perform_request(web_method,args={})
    ts=Time.now.to_i
    hash=Digest::SHA1.hexdigest(shared_secret+ts.to_s)
    args.merge! :api_key=>api_key, :ts=>ts, :hash=>hash
    url=URL.new web_method, args
    puts "\n\n#{url}\n\n" if (web_method=="get_slideshows_by_group")
    url.get @proxy
  end
  
end

end
