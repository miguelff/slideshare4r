require 'digest/sha1'

require 'slideshare/net'
require 'slideshare/model'

module Slideshare

  #
  # API façade. Provides a single entry point to every API method.
  #
  class API

    attr_reader :api_key, :shared_secret, :protocol, :proxy

    # Initializes a new instance of the API Façade
    # 
    # You must provide your api key and its complemenetary shared secret in order to
    # validate the API calls. If you don't have an API key, you have to apply
    # for one at http://www.slideshare.net/developers/applyforapi
    #
    # Optionally you can provide some arguments:
    #
    #:proxy_host and :proxy_port => if you are connecting to slideshare behind and HTTP proxy
    #:proxy_user and :proxy_pass => if the proxy needs authentication
    #:protocol => either :http or :https for secure connections
    #
    def initialize(api_key, shared_secret, args={})
      raise ArgumentError.new "api_key must be a String and it's #{api_key}" unless api_key.kind_of? String
      raise ArgumentError.new "shared_secret must be a String and it's #{shared_secret}" unless shared_secret.kind_of? String
      default_args={
        :protocol=>:https,
        :username=>nil,
        :password=>nil,
        :proxy_host=>nil,
        :proxy_port=>8080,
        :proxy_user=>nil,
        :proxy_pass=>nil
      }
      args=default_args.merge args

      raise ArgumentError.new "protocol must be either :http or :https" unless [:http,:https].member? args[:protocol]

      @protocol=args[:protocol]
      @api_key=api_key
      @shared_secret=shared_secret
      @proxy=Proxy.new(args[:proxy_host],args[:proxy_port],args[:proxy_user],args[:proxy_pass]) unless args[:proxy_host].nil?
    end
  
    #
    # Gets Slideshow Information
    #
    # see http://www.slideshare.net/developers/documentation#get_slideshow for additional documentation
    #
    # Required arguments. One of:
    # [+slideshow_id+] Id of the slideshow to be fetched.
    # [+slideshow_url+] URL of the slideshow to be fetched. This is required if slideshow_id is not set. If both are set, slideshow_id takes precedence.
    #
    # Optional arguments
    #
    # [+username+] Username of the requesting user
    # [+password+] Password of the requesting user
    # [+exclude_tags+] Exclude tags from the detailed information. true to exclude.
    # [+detailed+] Whether or not to include optional information. true to include, false (default) for basic information.
    #
    # returns an Slideshow instance
    #
    # raises Slideshare::ServiceError if an error related to the service occurs (wrong authorization, a required argument is missing...)
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

      raises Slideshare::ServiceError if an error related to the service occurs (wrong authorization, a required argument is missing...)
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
      
      response=get("get_slideshow",args)
      Slideshare::Slideshow.from_xml(response)
    end

  
    # Get slideshows with a certain tag
    #
    # See http://www.slideshare.net/developers/documentation#get_slideshows_by_tag for additional documentation
    #
    # Required arguments
    # [+tag+] The tag name
    #
    # Optional arguments
    # [+limit+] Max number of items to return (defaults to 10)
    # [+offset+] The number of slides to skip, before returning results.
    # [+detailed+] Whether or not to include optional information. true to include, false (default) for basic information.
    # 
    # returns a GetSlideshowsByTagResponse instance
    #
    # raises Slideshare::ServiceError if an error related to the service occurs (wrong authorization, a required argument is missing...)
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

       raises Slideshare::ServiceError if an error related to the service occurs (wrong authorization, a required argument is missing...)
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

      response=get("get_slideshows_by_tag",args)
      Slideshare::GetSlideshowsByTagResponse.from_xml(response)
    end

    # Gets the groups a user belongs to
    #
    # See http://www.slideshare.net/developers/documentation#get_slideshows_by_tag for additional documentation
    #
    # Required arguments
    # [+username_for+] name of user whose groups are being requested
    #
    # Optional arguments
    # [+username+] username of the requesting user
    # [+password+] password of the requesting user
    #
    # returns a GroupList instance, each element is a Group
    #
    # raises Slideshare::ServiceError if an error related to the service occurs (wrong authorization, a required argument is missing...)
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

         raises Slideshare::ServiceError if an error related to the service occurs (wrong authorization, a required argument is missing...)
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

      response=get("get_user_groups",args)
      Slideshare::GroupList.from_xml(response)
    end

    

    # Gets slideshows beonging to a certain group.
    #
    # See http://www.slideshare.net/developers/documentation#get_slideshows_by_group for additional documentation
    #
    # Required arguments
    # [+group_name+] Group name (as returned in +query_name+ in any of the elements returned by +get_user_groups method+)
    #
    # Optional arguments
    # [+limit+] Max number of items to return (defaults to 10)
    # [+offset+] The number of slides to skip, before returning results.
    # [+detailed+]  Whether or not to include optional information. true to include, false (default) for basic information.
    #
    # returns a GetSlideshowsByGroupResponse instance
    #
    # raises Slideshare::ServiceError if an error related to the service occurs (wrong authorization, a required argument is missing...)
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

       raises Slideshare::ServiceError if an error related to the service occurs (wrong authorization, a required argument is missing...)
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

      response=get("get_slideshows_by_group",args)
      Slideshare::GetSlideshowsByGroupResponse.from_xml(response)
    end

    # Gets slideshows beonging to a certain user.
    #
    # See http://www.slideshare.net/developers/documentation#get_slideshows_by_user for additional documentation
    #
    # Required arguments
    # [+username_for+] Name of the user whose groups are being requested
    #
    # Optional arguments
    # [+limit+] Max number of items to return (defaults to 12)
    # [+offset+] The number of slides to skip, before returning results.
    # [+detailed+] Whether or not to include optional information. true to include, false (default) for basic information.
    # [+username+] Username of the requesting user
    # [+password+] Password of the requesting user
    #
    # returns a GetSlideshowsByUserResponse instance
    #
    # raises Slideshare::ServiceError if an error related to the service occurs (wrong authorization, a required argument is missing...)
    def get_slideshows_by_user(args={})
      usage=%q{
       Gets slideshows beonging to a certain user.

       See http://www.slideshare.net/developers/documentation#get_slideshows_by_user for additional documentation

       Required arguments
          :username_for => name of the user whose groups are being requested

       Optional arguments

          :limit => max number of items to return (defaults to 10)
          :offset => the number of slides to skip, before returning results.
          :detailed => Whether or not to include optional information. true to include, false (default) for basic information.
          :username => username of the requesting user
          :password => password of the requesting user

       returns a GetSlideshowsByUserResponse instance

       raises Slideshare::ServiceError if an error related to the service occurs (wrong authorization, a required argument is missing...)
      }
      raise ArgumentError.new "No arguments provided. Usage:\n#{usage}" if args.empty?
      default_args={
        :username_for =>nil,
        :limit =>12,
        :offset=>nil,
        :detailed=>false,
        :username=>nil,
        :password=>nil
      }

      args=default_args.merge args
      args.reject!{|k,v| args[k].nil?}

      raise ArgumentError.new ":username_for must be a string and it's #{args[:username_for]}" unless args[:username_for].kind_of? String
      raise ArgumentError.new ":password must be provided for :username=>#{args[:username]}" unless args[:username].nil? or not args[:password].nil?
      raise ArgumentError.new ":limit must be a number greater than 0 and it's #{args[:limit]}" unless args[:limit].kind_of? Fixnum and args[:limit] > 0
      raise ArgumentError.new ":offset must be a number greater than 0 and it's #{args[:offset]}" unless args[:offset].nil? or (args[:offset].kind_of? Fixnum and args[:offset] > 0)
      raise ArgumentError.new ":detailed must be true or false, but it's #{args[:detailed]}" unless args[:detailed]==true or args[:detailed]==false

      args[:detailed] = args[:detailed] ? 1 : 0

      response=get("get_slideshows_by_user",args)
      Slideshare::GetSlideshowsByUserResponse.from_xml(response)
    end


    # Performs a search for slideshows
    #
    # See http://www.slideshare.net/developers/documentation#search_slideshows for additional documentation
    #
    # Required parameters     
    # [+q+] The query string
    #
    # Optional parameters  
    # [+page+] The page number of the results (works in conjunction with items_per_page), default is 1
    # [+items_per_page+] Number of results to return per page, default is 12
    # [+lang+] Language of slideshows (default is English, +:en+) (+:"**"+ for All,+:es+ for Spanish, +:pt+ for Portuguese,+:fr+ for French, +:it+ for Italian, +:nl+ for Dutch, +:de+ for German,+:zh+ for Chinese,+:ja+ for Japanese, +:ko+ for Korean, +:ro+ for Romanian, +:"!!"+ for Other)
    # [+sort+] Sort order (default is +:relevance+) (+:mostviewed+,+:mostdownloaded+,+:latest+)
    # [+upload_date+] The time period you want to restrict your search to. +:week+ would restrict to the last week. (default is +:any+) (+:week+, +:month+, +:year+)
    # [+search_in_tags_only+] Set to +true+ if you want to search only in tags. Defaults to +false+ (search in every field)
    # [+restrict_to_downloadables+] Set to +true+ if you want to search only for downloadable content. Defaults to 'false'.
    # [+fileformat+] File format to search for. Default is +:all+ (+:pdf+, +:ppt+, +:odp+ (Open Office) +:pps+ (PowerPoint Slideshow) +:pot+ (PowerPoint template))
    # [+file_type+] File type to search for. Default is +:all+. (+:presentations+, +:documents+, +:webinars+,+:videos+)
    # [+restrict_to_cc+] Set to +true+ to only retrieve results under the Creative Commons license.
    # [+restrict_to_cc_adapt+] Set to +true+ to restrict the retrieval to results under Creative Commons that allow adaption or modification. Defaults to +false+
    # [+restrict_to_cc_commercial+] Set to +true+ to restrict the retrieval to results under commercial Creative Commons license. Defaults to +false+
    # [+detailed+] Whether or not to include optional information. +true+ to include, +false+ (default) for basic information.
    #
    # returns an instance of SearchResults
    #
    # raises Slideshare::ServiceError if an error related to the service occurs (wrong authorization, a required argument is missing...)
    def search_slideshows(args={})
      usage=%q{
     Performs a search for slideshows

     See http://www.slideshare.net/developers/documentation#search_slideshows for additional documentation

     Required parameters

        :q => the query string

     Optional parameters

       :page => The page number of the results (works in conjunction with items_per_page), default is 1
       :items_per_page => Number of results to return per page, default is 12
       :lang => Language of slideshows (default is English, 'en') ('**':All,'es':Spanish,'pt':Portuguese,'fr':French,'it':Italian,'nl':Dutch, 'de':German,'zh':Chinese,'ja':Japanese,'ko':Korean,'ro':Romanian, '!!':Other)
       :sort => Sort order (default is :relevance) (:mostviewed,:mostdownloaded,:latest)
       :upload_date => The time period you want to restrict your search to. :week would restrict to the last week. (default is :any) (:week, :month, :year)
       :search_in_tags_only => Set to 'true' if you want to search only in tags. Defaults to 'false' (search in every field)
       :restrict_to_downloadables= > Set to 'true' if you want to search only for downloadable content. Defaults to 'false'.
       :fileformat => File format to search for. Default is :all (:pdf, :ppt, :odp (Open Office) :pps (PowerPoint Slideshow) :pot (PowerPoint template))
       :file_type => File type to search for. Default is :all. (:presentations, :documents, :webinars,:videos)
       :restrict_to_cc => Set to 'true' to only retrieve results under the Creative Commons license.
       :restrict_to_cc_adapt => Set to 'true' to restrict the retrieval to results under Creative Commons that allow adaption or modification. Defaults to 'false'
       :restrict_to_cc_commercial => Set to 'true' to restrict the retrieval to results under commercial Creative Commons license. Defaults to 'false'
       :detailed => Whether or not to include optional information. 'true' to include, 'false' (default) for basic information.

      returns => an instance of SearchResults

      raises Slideshare::ServiceError if an error related to the service occurs (wrong authorization, a required argument is missing...)
      }
      raise ArgumentError.new "No arguments provided. Usage:\n#{usage}" if args.empty?
      default_args={
        :q => nil,
        :page => 1,
        :items_per_page => 12,
        :lang=>:en,
        :sort=>:relevance,
        :upload_date=>:any,
        :search_in_tags_only => false,
        :restrict_to_downloadables=>false,
        :file_format=>:all,
        :file_type=>:all,
        :restrict_to_cc => false,
        :restrict_to_cc_adapt => false,
        :restrict_to_cc_commercial => false,
        :detailed=> false
      }
      valid_langs = ["**".to_sym, :en, :en, :pt, :fr, :it, :nl, :de, :zh, :ja, :co, :ro, "!!".to_sym]
      valid_sort_orders = [:relevance, :mostviewed, :mostdownloaded, :latest]
      valid_upload_dates = [:any, :week, :month, :year]
      valid_file_formats = [:all, :pdf, :ppt, :odp, :pps, :pot]
      valid_file_types = [:all, :presentations, :documents, :webinars,:videos]

      args=default_args.merge args
      args.reject!{|k,v| args[k].nil?}

      raise ArgumentError.new ":q must be a string and it's #{args[:q]}" unless args[:q].kind_of? String
      raise ArgumentError.new ":page must be a positive interger and it's #{args[:page]}" unless args[:page].kind_of? Fixnum and args[:page] > 0
      raise ArgumentError.new ":items_per_page must be a positive interger and it's #{args[:items_per_page]}" unless args[:items_per_page].kind_of? Fixnum and args[:items_per_page] > 0
      raise ArgumentError.new ":lang must be one of #{valid_langs.join(",")} and it's #{args[:lang]}" unless valid_langs.member? args[:lang]
      raise ArgumentError.new ":sort must be one of #{valid_sort_orders.join(",")} and it's #{args[:sort]}" unless valid_sort_orders.member? args[:sort]
      raise ArgumentError.new ":search_in_tags_only must be true or false and it's #{args[:search_in_tags_only]}" unless args[:search_in_tags_only]==true or args[:search_in_tags_only]==false
      raise ArgumentError.new ":upload_date must be one of #{valid_upload_dates.join(",")} and it's #{args[:upload_date]}" unless valid_upload_dates.member? args[:upload_date]
      raise ArgumentError.new ":restrict_to_downloadables must be true or false and it's #{args[:restrict_to_downloadables]}" unless args[:restrict_to_downloadables]==true or args[:restrict_to_downloadables]==false
      raise ArgumentError.new ":file_format must be one of #{valid_file_formats.join(",")} and it's #{args[:file_format]}" unless valid_file_formats.member? args[:file_format]
      raise ArgumentError.new ":file_type must be one of #{valid_file_types.join(",")} and it's #{args[:file_type]}" unless valid_file_types.member? args[:file_type]
      raise ArgumentError.new ":restrict_to_cc must be true or false and it's #{args[:restrict_to_cc]}" unless args[:restrict_to_cc]==true or args[:restrict_to_cc]==false
      raise ArgumentError.new ":restrict_to_cc_adapt must be true or false and it's #{args[:restrict_to_cc_adapt]}" unless args[:restrict_to_cc_adapt]==true or args[:restrict_to_cc_adapt]==false
      raise ArgumentError.new ":restrict_to_cc_commercial must be true or false and it's #{args[:restrict_to_cc_commercial]}" unless args[:restrict_to_cc_commercial]==true or args[:restrict_to_cc_commercial]==false
      raise ArgumentError.new ":detailed must be true or false and it's #{args[:detailed]}" unless args[:detailed]==true or args[:detailed]==false

      args[:what]=:tag if args[:search_in_tags_only]
      args.delete :search_in_tags_only
      
      args[:download]='0' if args[:restrict_to_downloadables]
      args.delete :restrict_to_downloadables

      args[:cc]='1' if args[:restrict_to_cc]
      args[:cc_adapt]='1' if args[:restrict_to_cc_adapt]
      args[:cc_commercial]='1' if args[:restrict_to_cc_commercial]
      [:restrict_to_cc,:restrict_to_cc_adapt,:restrict_to_cc_commercial].each{|k| args.delete k}

      args[:detailed] = args[:detailed] ? 1 : 0

      response=get("search_slideshows",args)
      Slideshare::SearchResults.from_xml(response)
    end

    
    # Gets the contacts of a certain user
    #
    # See http://www.slideshare.net/developers/documentation#get_user_contacts for additional documentation
    #
    # Required arguments
    # [+username_for+] Name of the user whose contacts are being requested
    #
    # Optional arguments
    # [+limit+] Max number of items to return (defaults to 12)
    # [+offset+] The number of slides to skip, before returning results.
    #
    # returns an instance of ContactList. Each element in the list modelles a user contact
    #
    # raises Slideshare::ServiceError if an error related to the service occurs (wrong authorization, a required argument is missing...)
    def get_user_contacts(args={})
      usage=%q{
         Gets the groups a user belongs to

         See http://www.slideshare.net/developers/documentation#get_slideshows_by_tag for additional documentation

         Required arguments

            :username_for => name of the user whose contacts are being requested

         Optional arguments

            :limit => Max number of items to return (defaults to 12)
            :offset => The number of slides to skip, before returning results.

         returns a list of Contact instances

         raises Slideshare::ServiceError if an error related to the service occurs (wrong authorization, a required argument is missing...)
      }
      raise ArgumentError.new "No arguments provided. Usage:\n#{usage}" if args.empty?

      default_args={
        :username_for =>nil,
        :limit =>12,
        :offset=>nil,
      }

      args=default_args.merge args
      args.reject!{|k,v| args[k].nil?}

      raise ArgumentError.new ":username_for must be a string and it's #{args[:username_for]}" unless args[:username_for].kind_of? String
      raise ArgumentError.new ":limit must be a number greater than 0 and it's #{args[:limit]}" unless args[:limit].kind_of? Fixnum and args[:limit] > 0
      raise ArgumentError.new ":offset must be a number greater than 0 and it's #{args[:offset]}" unless args[:offset].nil? or (args[:offset].kind_of? Fixnum and args[:offset] > 0)
      
      response=get("get_user_contacts",args)
      Slideshare::ContactList.from_xml(response)
    end

    # Gets the tags of the user whose credentials are provided
    #
    # See http://www.slideshare.net/developers/documentation#get_user_tags for additional documentation
    #
    # Required arguments
    # [+username+] Username of the requesting user
    # [+password+] Password of the requesting user
    #
    # returns a TagList instance
    #
    # raises Slideshare::ServiceError if an error related to the service occurs (wrong authorization, a required argument is missing...)
    def get_user_tags(args={})
      usage=%q{
           Gets the tags of the user whose credentials are provided

           See http://www.slideshare.net/developers/documentation#get_user_tags for additional documentation

           Required arguments
           :username => Username of the requesting user
           :password => Password of the requesting user

           returns a list of Tag instances
      }
      raise ArgumentError.new "No arguments provided. Usage:\n#{usage}" if args.empty?
      default_args={
        :username=>nil,
        :password=>nil
      }

      args=default_args.merge args
      args.reject!{|k,v| args[k].nil?}

      raise ArgumentError.new ":username must be a string and it's #{args[:username]}" unless args[:username].kind_of? String
      raise ArgumentError.new ":password must be a string and it's #{args[:password]}" unless args[:password].kind_of? String
      
      response=get("get_user_tags",args)
      Slideshare::TagList.from_xml(response)
    end


    # Edits the slideshow with the given id
    # 
    # See http://www.slideshare.net/developers/documentation#edit_slideshow for additional documentation
    #
    # Required arguments
    # [+slideshow_id+] Id of the slideshow
    # [+username+] Username of the owner of the slideshow
    # [+password+] Password of the owner of the slideshow
    #
    # Optional arguments
    # [+title+] The new title for the slideshow
    # [+description+] The new description for the slideshow
    # [+tags+] A list of strings, representing the new tags for the slideshow
    # [+make_private+] Should be true if you want to make the slideshow private. If this is not set, following arguments will not be considered
    # [+generate_secret_url+] Set to true to generate a secret URL for the slideshow. Requires make_slideshow_private to be true
    # [+allow_embeds+] Set to true if other websites should be allowed to embed the slideshow. Requires make_slideshow_private to be true
    # [+share_with_contacts+] Set to true if your contacts on SlideShare can view the slideshow. Requires make_slideshow_private to be true
    #
    # Returs true if the slideshow has been successfully updated, false otherwise
    #
    # raises Slideshare::ServiceError if an error related to the service occurs (wrong authorization, a required argument is missing...)
    def edit_slideshow(args={})
      usage=%q{
           Edits the slideshow with the given id

           See http://www.slideshare.net/developers/documentation#get_user_tags for additional documentation

           Required arguments
           [+slideshow_id+] Id of the slideshow
           [+username+] Username of the owner of the slideshow
           [+password+] Password of the owner of the slideshow

           Optional arguments
           :title => The new title for the slideshow
           :description => The new description for the slideshow
           :tags => A list of strings, representing the new tags for the slideshow
           :make_private => Should be true if you want to make the slideshow private. If this is not set, following arguments will not be considered
           :generate_secret_url => Generate a secret URL for the slideshow. Requires make_slideshow_private to be true
           :allow_embeds => Sets if other websites should be allowed to embed the slideshow. Requires make_slideshow_private to be true
           :share_with_contacts => Sets if your contacts on SlideShare can view the slideshow. Requires make_slideshow_private to be true

           Returs true if the slideshow has been successfully updated, false otherwise

           raises Slideshare::ServiceError if an error related to the service occurs (wrong authorization, a required argument is missing...)
      }
      raise ArgumentError.new "No arguments provided. Usage:\n#{usage}" if args.empty?
      default_args={
        :slideshow_id => nil,
        :username => nil,
        :password => nil,
        :title=>nil,
        :description=>nil,
        :tags=>nil,
        :make_private => false,
        :generate_secret_url => nil,
        :allow_embeds => nil,
        :share_with_contacts=>nil
      }

      args=default_args.merge args
      args.reject!{|k,v| args[k].nil?}

      raise ArgumentError.new ":slideshow_id must be a string and it's #{args[:slideshow_id]}" unless args[:slideshow_id].kind_of? String
      raise ArgumentError.new ":username must be a string and it's #{args[:username]}" unless args[:username].kind_of? String
      raise ArgumentError.new ":password must be a string and it's #{args[:password]}" unless args[:password].kind_of? String
      raise ArgumentError.new ":title must be a string and it's #{args[:title]}" unless args[:title].nil? or args[:title].kind_of? String
      raise ArgumentError.new ":description must be a string and it's #{args[:description]}" unless args[:description].nil? or args[:description].kind_of? String
      raise ArgumentError.new ":tags must be a list of strings and it's #{args[:tags]}" unless args[:tags].nil? or args[:tags].kind_of? Array
      raise ArgumentError.new ":make_private must be a true or false and it's #{args[:make_private]}" unless args[:make_private]==true or args[:make_private]==false
      raise ArgumentError.new ":generate_secret_url only makes sense if make_private_is_true" if args[:make_private]==false and args.member? :generate_secret_url
      raise ArgumentError.new ":allow_embeds only makes sense if make_private_is_true" if args[:make_private]==false and args.member? :allow_embeds
      raise ArgumentError.new ":share_with_contacts only makes sense if make_private_is_true" if args[:make_private]==false and args.member? :share_with_contacts
      raise ArgumentError.new "if present, :generate_secret_url must be true or false and it's #{args[:generate_secret_url]}" unless args[:generate_secret_url].nil? or args[:generate_secret_url]==true or args[:generate_secret_url]==false
      raise ArgumentError.new "if present, :allow_embeds must be true or false and it's #{args[:allow_embeds]}" unless args[:allow_embeds].nil? or args[:allow_embeds]==true or args[:allow_embeds]==false
      raise ArgumentError.new "if present, :share_with_contacts must be true or false and it's #{args[:share_with_contacts]}" unless args[:share_with_contacts].nil? or args[:share_with_contacts]==true  or args[:share_with_contacts]==false

      if args[:title]
        args[:slideshow_title]=args[:title]
        args.delete :title
      end

      if args[:description]
        args[:slideshow_description]=args[:description]
        args.delete :description
      end

      if args[:tags]
        args[:slideshow_tags]=args[:tags].join(", ")
        args.delete :tags
      end

      if args[:make_private]
        args[:make_slideshow_private]='Y'
        args.delete :make_private
      end

      args[:generate_secret_url] = args[:generate_secret_url] ? "Y" : "N" if args.member? :generate_secret_url
      args[:allow_embeds] = args[:allow_embeds] ? "Y" : "N" if args.member? :allow_embeds
      args[:share_with_contacts] = args[:share_with_contacts] ? "Y" : "N" if args.member? :share_with_contacts

      response=get("edit_slideshow",args)
      Slideshare::EditSlideshowResponse.from_xml(response).success
    end

    # Deletes the slideshow with the given id
    #
    # See http://www.slideshare.net/developers/documentation#delete_slideshow for additional documentation
    #
    # Required arguments
    # [+slideshow_id+] Id of the slideshow
    # [+username+] Username of the owner of the slideshow
    # [+password+] Password of the owner of the slideshow
    # 
    # Returs true if the slideshow has been successfully deleted, false otherwise
    #
    # raises Slideshare::ServiceError if an error related to the service occurs (wrong authorization, a required argument is missing...)
    def delete_slideshow(args={})
        usage=%q{
           Deletes the slideshow with the given id

           See http://www.slideshare.net/developers/documentation#delete_slideshow for additional documentation

           Required arguments
           [+slideshow_id+] Id of the slideshow
           [+username+] Username of the owner of the slideshow
           [+password+] Password of the owner of the slideshow

           Returs true if the slideshow has been successfully deleted, false otherwise

           raises Slideshare::ServiceError if an error related to the service occurs (wrong authorization, a required argument is missing...)
      }
      raise ArgumentError.new "No arguments provided. Usage:\n#{usage}" if args.empty?
      default_args={
        :slideshow_id => nil,
        :username => nil,
        :password => nil,
      }

      args=default_args.merge args
      args.reject!{|k,v| args[k].nil?}

      raise ArgumentError.new ":slideshow_id must be a string and it's #{args[:slideshow_id]}" unless args[:slideshow_id].kind_of? String
      raise ArgumentError.new ":username must be a string and it's #{args[:username]}" unless args[:username].kind_of? String
      raise ArgumentError.new ":password must be a string and it's #{args[:password]}" unless args[:password].kind_of? String

      response=get("delete_slideshow",args)
      Slideshare::EditSlideshowResponse.from_xml(response).success
    end

    # Favorites the slideshow with the given id
    #
    # See http://www.slideshare.net/developers/documentation#add_favorite for additional documentation
    #
    # Required arguments
    # [+slideshow_id+] Id of the slideshow
    # [+username+] Username of the owner of the slideshow
    # [+password+] Password of the owner of the slideshow
    #
    # Returs true if the slideshow has been successfully favorited, false otherwise
    #
    # raises Slideshare::ServiceError if an error related to the service occurs (wrong authorization, a required argument is missing...)
    def favorite_slideshow(args={})
        usage=%q{
           Marks the slideshow with the given id as favorite

           See http://www.slideshare.net/developers/documentation#add_favorite for additional documentation

           Required arguments
           [+slideshow_id+] Id of the slideshow
           [+username+] Username of the owner of the slideshow
           [+password+] Password of the owner of the slideshow

           Returs true if the slideshow has been successfully favorited, false otherwise

           raises Slideshare::ServiceError if an error related to the service occurs (wrong authorization, a required argument is missing...)
      }
      raise ArgumentError.new "No arguments provided. Usage:\n#{usage}" if args.empty?
      default_args={
        :slideshow_id => nil,
        :username => nil,
        :password => nil,
      }

      args=default_args.merge args
      args.reject!{|k,v| args[k].nil?}

      raise ArgumentError.new ":slideshow_id must be a string and it's #{args[:slideshow_id]}" unless args[:slideshow_id].kind_of? String
      raise ArgumentError.new ":username must be a string and it's #{args[:username]}" unless args[:username].kind_of? String
      raise ArgumentError.new ":password must be a string and it's #{args[:password]}" unless args[:password].kind_of? String

      response=get("add_favorite",args)
      Slideshare::FavoriteSlideshowResponse.from_xml(response).success
    end

    # Checks if the slideshow with the given id is favorite for the user whose credentials are provided
    #
    # See http://www.slideshare.net/developers/documentation#check_favorite for additional documentation
    #
    # Required arguments
    # [+slideshow_id+] Id of the slideshow
    # [+username+] Username of the owner of the slideshow
    # [+password+] Password of the owner of the slideshow
    #
    # Returs true if the slideshow is favorite for the user authenticated
    #
    # raises Slideshare::ServiceError if an error related to the service occurs (wrong authorization, a required argument is missing...)
    def check_favorite(args={})
        usage=%q{
           Checks if the slideshow with the given id is favorite for the user whose credentials are provided

           See http://www.slideshare.net/developers/documentation#check_favorite for additional documentation

           Required arguments
           [+slideshow_id+] Id of the slideshow
           [+username+] Username of the owner of the slideshow
           [+password+] Password of the owner of the slideshow

           Returs true if the slideshow is favorite for the user authenticated

           raises Slideshare::ServiceError if an error related to the service occurs (wrong authorization, a required argument is missing...)
      }
      raise ArgumentError.new "No arguments provided. Usage:\n#{usage}" if args.empty?
      default_args={
        :slideshow_id => nil,
        :username => nil,
        :password => nil,
      }

      args=default_args.merge args
      args.reject!{|k,v| args[k].nil?}

      raise ArgumentError.new ":slideshow_id must be a string and it's #{args[:slideshow_id]}" unless args[:slideshow_id].kind_of? String
      raise ArgumentError.new ":username must be a string and it's #{args[:username]}" unless args[:username].kind_of? String
      raise ArgumentError.new ":password must be a string and it's #{args[:password]}" unless args[:password].kind_of? String

      response=get("check_favorite",args)
      Slideshare::CheckFavoriteResponse.from_xml(response).marked_as_favorite
    end

    private


    def get(web_method,args={})
      perform_request web_method,:get,args
    end

    def post(web_method,args={})
      perform_request web_method,:post,args
    end

    # performs an HTTP request to the given webmethod using the given optional arguments
    #
    # raise Slideshare::ServiceError if an error related to the service occurs
    # (wrong authorization, a required argument is missing...) when
    # requesting the service URL.
    def perform_request(web_method,method,args={})
      ts=Time.now.to_i
      hash=Digest::SHA1.hexdigest(shared_secret+ts.to_s)
      args.merge! :api_key=>api_key, :ts=>ts, :hash=>hash
      req=Request.new web_method, protocol, args
      case method
      when :get
        req.perform_get @proxy
      when :post
        req.perform_multipart_post @proxy
      else
        raise ArgumentError.new "method must be :get or :post, but is #{method}"
      end
    end
  
  end

end
