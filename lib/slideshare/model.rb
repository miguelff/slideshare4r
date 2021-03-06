require 'rubygems'
require 'nokogiri'
require 'date'

module Slideshare 
    
  
  # Classes that include this module, extend its eigenclass by adding
  # +from_xml(xml_str)+ method, which builds a new instance of the
  # class extended by unmarshalling the XML document provided.
  #
  module Builder
      
    # When clases include this module, they
    # extend they functionality with this
    # module's instance methods
    def self.included(base)
      base.extend(self)
    end

      
 
    # Takes an XML document as a string or Nokogiri::XML::Element, and extracts
    # certain information from it adding new properties to the instance
    # being built on the fly.
    #
    # The information to gather from the XML document is conditioned by two dictionaries,
    # respectively returned by:
    #
    # * self.extraction_rules
    # * self.exclusion_rules
    #
    # both are defined as class methods in the classes that includes this module
    #
    # This first dictionary contains the name of the instance property as the key,
    # and a list indicating how to extract it from the XML as the value. The latter
    # must have at least one first element, which is the XPATH expression that points
    # to the xml that encloses the value of the property. An optional second parameter
    # is a block that receives one paremeter (the XML node pointed by the expression)
    # and returns the information to set on the property. If not provided, the block will
    # get the inner text of the node.
    #
    # As an example, imagine the following class:
    #
    #         class Slideshow
    #          include Builder
    #
    #          def self.extraction_rules
    #            {
    #              :id=>["Slideshow/ID"],
    #              :title=>["Slideshow/Title",lambda{|x| x.value.upcase}]
    #            }
    #          end
    #         end
    #
    #
    # and the following xml document
    #
    #         xml_str=%q{
    #         <Slideshow>
    #          <ID>foo</ID>
    #          <Title>bar/Title>
    #         </Slideshow>
    #         }
    #
    # if we make this call:
    #
    #         Slideshow.from_xml(xml_str)
    #
    # we will obtain something like
    #
    #         <Slideshow:0x1014e11f8 @id="foo", @title="BAR">
    #
    # this instance will also have accessor methods for both id, and title.
    #
    # The second dictionary, restricts what to extract. It defines a ser of rules to apply
    # to the properties extracted from the XML, if a rules applied on a property, evaluates
    # to true, that property will be excluded from de set of properties to define on the instance.
    # Taking again the example above, imagine that we define Slideshow class as follows:
    #
    #         class Slideshow
    #          include Builder
    #
    #          def self.extraction_rules
    #            {
    #              :id=>["Slideshow/ID"],
    #              :title=>["Slideshow/Title",lambda{|x| x.value.upcase}]
    #            }
    #          end
    #
    #          def self.exclusion_rules
    #            {
    #               :title=>lambda{|title| title.size < 10}
    #          end
    #         end
    #
    # This will omit the definition of the title property, if title has less than 10 characters,
    # so if we provide again the same XML document
    #
    #         xml_str=%q{
    #         <Slideshow>
    #          <ID>foo</ID>
    #          <Title>bar/Title>
    #         </Slideshow>
    #         }
    #
    # and build a slideshow from it
    #
    #         Slideshow.from_xml(xml_str)
    #
    # we will obtain something like
    #
    #         <Slideshow:0x1014e11f8 @id="foo">
    #
    # (i.e.) title was excluded from the set of properties defined, as it is "bar" and has less
    # that 10 characters.
    #
    def from_xml(xml_doc)
      extraction_rules = (self.respond_to? :extraction_rules) ? self.extraction_rules : {}
      exclusion_rules = (self.respond_to? :exclusion_rules) ? self.exclusion_rules : {}
      instance=self.new
      xml_doc  = Nokogiri::XML(xml_doc.to_s) unless xml_doc.kind_of? Nokogiri::XML::Node
      extraction_rules.each_pair do |attribute,rule|
        path=rule[0]
        extraction_predicate=rule[1] ||= lambda{|x| x.text}
        property_value=extraction_predicate.call(xml_doc.xpath(path))
        exclusion_rule=exclusion_rules[attribute]
        unless exclusion_rule and exclusion_rule.call(property_value)
          instance.instance_variable_set("@#{attribute}",property_value)
          instance.instance_eval "def #{attribute}; @#{attribute}; end"
          instance.instance_eval "def #{attribute}=(value); @#{attribute}=value;end"
        end
      end
      instance
    end
  end

  # Modelles the response of API#check_favorite method
  #
  # The following is the structure  of the XML returned by the API web method,
  # which will be unmarshalled into an instance of this class.
  #
  #<SlideShow>
  # <SlideShowID>SlideShowID</SlideShowID>
  # <User>User ID</User>
  # <Favorited>true: Slideshow was favorited, false otherwise</Favorites>
  #</SlideShow>
  #
  # An instance of CheckFavoriteResponse has the following properties:
  #
  # [+slideshow_id+] The id of the slideshow we want to know if it has been favorited
  # [+user_id+] Id for the user we want to know if has favorited the slideshow
  # [+marked_as_favorite+] true if the slideshow is favorited; false otherwise
  #
  class CheckFavoriteResponse
    include Builder

    def self.extraction_rules
      {
        :slideshow_id => ["/SlideShow/SlideShowID"],
        :user_id => ["/SlideShow/User"],
        :marked_as_favorite =>["/SlideShow/Favorited",lambda{|node| node.text=="true" ? true : false }]
      }
    end
  end

  # Modelles a Group
  #
  # The following is the structure  of the XML returned by the API web method,
  # which will be unmarshalled into an instance of this class.
  #
  #        <Contact>
  #          <Userame>{ Username }</Username>
  #          <NumSlideshows>{ Number of Slideshows }</NumSlideshows>
  #          <NumComments>{ Number of Comments }</NumComments>
  #        <Contact>
  #
  # An instance of group has the following properties:
  #
  # [+name+] Contact's username
  # [+num_slideshows+] Number of slideshows owned by this contact
  # --
  #  What's the exact meaning of num_comments?
  #
  #  - Comments submitted by the contact (on any slideshow)
  #  - Comments submitted by the contact (on the requesting user slideshow?)
  #
  #  I guess is the first one because get_user_contacts doesn't need any kind of
  #  authentication. But it can drive to confusion.
  # ++
  # [+num_comments+] Number of comments posted? by the contact
  #
  class Contact
    include Builder

    def self.extraction_rules
      {
        :name           => ["Contact/Username"],
        :num_slideshows => ["Contact/NumSlideshows",lambda{|node| node.text.to_i}],
        :num_comments   => ["Contact/NumComments",lambda{|node| node.text.to_i}],
      }
    end
  end

  # Modelles a list of users
  #
  # The following is the structure  of the XML that represents a list of contacts,
  # which will be unmarshalled into an instance of this class.
  #
  #        <Contacts>
  #          <Contact>
  #          ...
  #          </Contact>
  #          <Contact>
  #          ...
  #          </Contact>
  #        </Contacts>
  #
  # An instance of ContactList has the following properties:
  #
  # [+items+] A list of Contact instances
  #
  class ContactList
    include Builder

    def self.extraction_rules
      {
        :items =>["/Contacts/Contact",lambda{|nodeset| nodeset.map{|element| Contact.from_xml(element.to_s)}}],
      }
    end

    #tries to delagate unhandled requests to :items list
    def method_missing(method,*args,&b)
      if items.respond_to? method
        items.method(method).call(*args,&b)
      else
        super.method_missing(method, *args,&b)
      end
    end
     
  end

  # Modelles the response of API#delete_slideshow method
  #
  # The following is the structure  of the XML returned by the API web method,
  # which will be unmarshalled into an instance of this class.
  #
  #   <SlideShowDeleted>
  #     <SlideShowID>SlideShowID</SlideShowID>
  #   </SlideShowDeleted>
  #
  # An instance of EditSlideshowResponse has the following properties:
  #
  # [+slideshow_id+] The id of the slideshow deleted
  # [+success+] true if the slideshow was successfully deleted; false otherwise
  #
  class DeleteSlideshowResponse
    include Builder

    def self.extraction_rules
      {
        :slideshow_id => ["/SlideShowDeleted/SlideShowID"],
        :success => ["/SlideShowDeleted/SlideShowID",lambda{|node| node.empty? ? false : true}]
      }
    end
  end

  # Modelles the response of API#edit_slideshow method
  #
  # The following is the structure  of the XML returned by the API web method,
  # which will be unmarshalled into an instance of this class.
  #
  #   <SlideShowEdited>
  #     <SlideShowID>SlideShowID</SlideShowID>
  #   </SlideShowEdited>
  #
  # An instance of DeleteSlideshowResponse has the following properties:
  #
  # [+slideshow_id+] The id of the slideshow edited
  # [+success+] true if the slideshow was successfully updated; false otherwise
  #
  class EditSlideshowResponse
    include Builder

    def self.extraction_rules
      {
        :slideshow_id => ["/SlideShowEdited/SlideShowID"],
        :success => ["/SlideShowEdited/SlideShowID",lambda{|node| node.empty? ? false : true}]
      }
    end
  end

  # Modelles the response of API#favorite_slideshow method
  #
  # The following is the structure  of the XML returned by the API web method,
  # which will be unmarshalled into an instance of this class.
  #
  #  <SlideShow>
  #   <SlideShowID>SlideShowID</SlideShowID>
  #  </SlideShow>
  #
  # An instance of FavoriteSlideshowResponse has the following properties:
  #
  # [+slideshow_id+] The id of the slideshow favorited
  # [+success+] true if the slideshow was successfully favorited; false otherwise
  #
  class FavoriteSlideshowResponse
    include Builder

    def self.extraction_rules
      {
        :slideshow_id => ["/SlideShow/SlideShowID"],
        :success => ["/SlideShow/SlideShowID",lambda{|node| node.empty? ? false : true}]
      }
    end
  end


  # Modelles the response of API#get_slideshows_by_group method
  #
  # The following is the structure  of the XML returned by the API web method,
  # which will be unmarshalled into an instance of this class.
  #
  #        <Group>
  #        <Name>{ Tag Name }</Name>
  #        <Count>{ Number of Slideshows }</Count>
  #        <Slideshow>
  #          { as in get_slideshow }
  #        </Slideshow>
  #        ...
  #        </Group>
  #
  # An instance of GetSlideshowsByGroupResponse has the following properties:
  #
  # [+slideshows+] A list of Slideshow instances tagged with the string used to make the search
  # [+total_number_of_results+] The total number of slideshows on slideshare that are tagged with the string searched
  # [+group_searched+] The string used to search a list of the slideshows tagged with it.
  #
  class GetSlideshowsByGroupResponse
    include Builder

    def self.extraction_rules
      {
        :slideshows              =>["//Slideshow",lambda{|nodeset| nodeset.map{|element| Slideshow.from_xml(element.to_s)}}],
        :total_number_of_results => ["/Group/Count",lambda{|node| node.text.to_i}],
        :group_searched          => ["/Group/Name"]
      }
    end

    #tries to delagate unhandled requests to :slideshows list
    def method_missing(method,*args,&b)
      if slideshows.respond_to? method
        slideshows.method(method).call(*args,&b)
      else
        super.method_missing(method, *args,&b)
      end
    end

  end

  # Modelles the response of API#get_slideshows_by_tag method
  #
  # The following is the structure  of the XML returned by the API web method,
  # which will be unmarshalled into an instance of this class.
  #
  #        <Tag>
  #        <Name>{ Tag Name }</Name>
  #        <Count>{ Number of Slideshows }</Count>
  #        <Slideshow>
  #          { as in get_slideshow }
  #        </Slideshow>
  #        ...
  #        </Tag>
  #
  # An instance of GetSlideshowsByTagResponse has the following properties:
  #
  # [+slideshows+]  A list of Slideshow instances tagged with the string used to make the search
  # [+total_number_of_results+] The total number of slideshows on slideshare that are tagged with the string searched
  # [+tag_searched+] The string used to search a list of the slideshows tagged with it.
  #
  class GetSlideshowsByTagResponse
    include Builder

    def self.extraction_rules
      {
        :slideshows               =>["//Slideshow",lambda{|nodeset| nodeset.map{|element| Slideshow.from_xml(element,to_s)}}],
        :total_number_of_results  => ["/Tag/Count",lambda{|node| node.text.to_i}],
        :tag_searched             => ["/Tag/Name"]
      }
    end

    #tries to delagate unhandled requests to :slideshows list
    def method_missing(method,*args,&b)
      if slideshows.respond_to? method
        slideshows.method(method).call(*args,&b)
      else
        super.method_missing(method, *args,&b)
      end
    end

  end

  # Modelles the response of API#get_slideshows_by_user method
  #
  # The following is the structure  of the XML returned by the API web method,
  # which will be unmarshalled into an instance of this class.
  #
  #        <User>
  #        <Name>{ username_for }</Name>
  #        <Count>{ Number of Slideshows }</Count>
  #        <Slideshow>
  #          { as in get_slideshow }
  #        </Slideshow>
  #        ...
  #        </Group>
  #
  # An instance of GetSlideshowsByUserResponse has the following properties:
  #
  # [+slideshows+] A list of Slideshow instances that belong to the user
  # [+total_number_of_results+] The total number of slideshows on slideshare that belong to the user
  # [+user_searched+] The string used to search a list of the slideshows tagged with it.
  #
  class GetSlideshowsByUserResponse
    include Builder

    def self.extraction_rules
      {
        :slideshows              => ["//Slideshow",lambda{|nodeset| nodeset.map{|element| Slideshow.from_xml(element.to_s)}}],
        :total_number_of_results => ["/User/Count",lambda{|node| node.text.to_i}],
        :user_searched          =>  ["/User/Name"]
      }
    end

    #tries to delagate unhandled requests to :slideshows list
    def method_missing(method,*args,&b)
      if slideshows.respond_to? method
        slideshows.method(method).call(*args,&b)
      else
        super.method_missing(method, *args,&b)
      end
    end
     
  end




  # Modelles a Group
  #
  # The following is the structure  of the XML returned by the API web method,
  # which will be unmarshalled into an instance of this class.
  #
  #          <Group>
  #          <Name>{ Group Name }</Name>
  #          <NumPosts>{ Number of Posts }</NumPosts>
  #          <NumSlideshows>{ Number of Slideshows }</NumSlideshows>
  #          <NumMembers>{ Number of Members }</NumMembers>
  #          <Created>{ Created date }</Created>
  #          <QueryName>{ Name used for querying (get_slideshows_by_group, etc) }</QueryName>
  #          <URL>{ Group URL }</URL>
  #         <Group>
  #
  # An instance of group has the following properties:
  #
  # [+name+] The group name
  # [+num_posts+] Number of posts published on this group
  # [+num_slideshows+] Number of slideshows belonging to this group
  # [+num_members+] Number of members of this group
  # [+created+] A +DateTime+ object indicating when the group was created
  # [+query_name+] a string used to make other queries (+get_slideshows_by_group+, etc)
  # [+url+] url of the group
  #
  class Group
    include Builder

    def self.extraction_rules
      {
        :name           => ["Group/Name"],
        :num_posts      => ["Group/NumPosts",lambda{|node| node.text.to_i}],
        :num_slideshows => ["Group/NumSlideshows",lambda{|node| node.text.to_i}],
        :num_members    => ["Group/NumMembers",lambda{|node| node.text.to_i}],
        :created        => ["Group/Created", lambda{|node| DateUtil::parse(node.text)}],
        :query_name     => ["Group/QueryName"],
        :url            => ["Group/URL"]
      }
    end
  end

  # Modelles a list of groups
  #
  # The following is the structure  of the XML that represents a list of groups,
  # which will be unmarshalled into an instance of this class.
  #
  #        <Groups>
  #        <Group>
  #        ...
  #        </Group>
  #        <Group>
  #        ...
  #        </Group>
  #        </Groups>
  #
  # An instance of GroupList has the following properties:
  #
  # [+items+] A list of group instances
  #
  class GroupList
    include Builder

    def self.extraction_rules
      {
        :items =>["/Groups/Group", lambda{|nodeset| nodeset.map{|element| Group.from_xml(element.to_s)}}],
      }
    end
    
    #tries to delagate unhandled requests to :items list
    def method_missing(method,*args,&b)
      if items.respond_to? method
        items.method(method).call(*args,&b)
      else
        super.method_missing(method, *args,&b)
      end
    end


  end

  # Modelles the result of searching for slideshows
  #
  # The following is the XML structure of the search results, which will
  # be unmarshalled into an instance of this class
  #
  #        <Slideshows>
  #        <Meta>
  #        <Query>{ query }</Query>
  #        <ResultOffset>{ the offset of this result (if pages were used)}
  #        </ResultOffset>
  #        <NumResults>{ number of results returned }</NumResults>
  #        <TotalResults>{ total number of results}</TotalResults>
  #        </Meta>
  #        <Slideshow>
  #        {as in get_slideshow}
  #        </Slideshow>
  #        ...
  #        </Slideshows>
  #
  # An instance of SearchResults contains the following properties
  #
  # [+items+] A list of the slideshows matching the query. Each element is an Slideshow instance
  # [+query+] The query performed
  # [+result_offset+] If present the offset of the result (if pages used)
  # [+total_number_of_results+] The total number of results that match the query
  #
  class SearchResults
    include Builder
    def self.extraction_rules
      {
        :items                 => ["//Slideshow",lambda{|nodeset| nodeset.map{|element| Slideshow.from_xml(element)}}],
        :query                   => ["/Slideshows/Meta/Query"],
        :result_offset           => ["/Slideshows/Meta/ResultOffset",lambda{|node| node.text.to_i}],
        :total_number_of_results => ["/Slideshows/Meta/TotalResults",lambda{|node| node.text.to_i}]
      }
    end

    #tries to delagate unhandled requests to items list
    def method_missing(method,*args,&b)
      if items.respond_to? method
        items.method(method).call(*args,&b)
      else
        super.method_missing(method, *args,&b)
      end
    end
  end

  # Modelles an error returned by any of the webmethods.
  # As the API doens't return errors as standard HTTP status codes,
  # we define this error as part of the model and not in the net module.
  #
  # The XML of a Service error is something as follows
  #
  #
  #   <SlideShareServiceError>
  #      <Message ID="9">SlideShow Not Found</Message>
  #   </SlideShareServiceError>
  #
  # An instance of this error, has the following properties
  #
  # [+:error_id+] A code that identifies the error
  # [+:message+] The error message
  #
  class ServiceError < StandardError
    include Builder

    def self.extraction_rules
      {
        :code=>["/SlideShareServiceError",lambda{|nodeset| nodeset.first["ID"].to_i}],
        :message=>["/SlideShareServiceError/Message"]
      }
    end

    def to_s
      "Error (#{code}): #{message}"
    end
  end
  

  
  # Modelles a Slideshow
  #
  # See http://www.slideshare.net/developers/documentation#get_slideshow
  #
  # The following is a the structure of the XML that describes a Slideshow
  #
  #         <Slideshow>
  #           <ID>{ slideshow id }</ID>
  #           <Title>{ slideshow title }</Title>
  #           <Description>{ slideshow description }</Description>
  #           <Status>{ 0 if queued for conversion, 1 if converting, 2 if converted,
  #                     3 if conversion failed }
  #           </Status>
  #           <Username>{ username }</Username>
  #           <URL>{ web permalink }</URL>
  #           <ThumbnailURL>{ thumbnail URL }</ThumbnailURL>
  #           <ThumbnailSmallURL>{ URL of smaller thumbnail }</ThumbnailSmallURL>
  #           <Embed>{ embed code }</Embed>
  #           <Created>{ date slideshow created }</Created>
  #           <Updated>{ date slideshow was last update }</Updated>
  #           <Language>{ language, as specified by two-letter code }</Language>
  #           <Format>ppt (or pdf, pps, odp, doc, pot, txt, rdf) </Format>
  #           <Download>{ 1 if available to download, else 0 }</Download>
  #           <DownloadUrl>{ returns if available to download }</DownloadUrl>
  #           <SlideshowType>{ 0 if presentation, 1 if document, 2 if a portfolio,
  #             3 if video }</SlideshowType>
  #           <InContest>{ 1 if part of a contest, 0 if not }</Download>
  #
  #           <UserID>{ userID }</UserID>
  #           <ExternalAppUserID>{ ExternalAppUserID if uploaded using an
  #                  external app }</ExternalAppUserID>
  #           <ExternalAppID>{ ExternalAppID for the external app }</ExternalAppID>
  #           <PPTLocation>{ PPTLocation }</ExternalAppUserID>
  #           <StrippedTitle>{ Stripped Title }</StrippedTitle>
  #           <Tags>
  #           <Tag Count="{ number of times tag has been used }" Owner="{ 1 if owner
  #                         has used the tag, else 0 }">{ tag name }
  #           </Tag>
  #           </Tags>
  #           <Audio>{ 0, or 1 if the slideshow contains audio }</Audio>
  #           <NumDownloads>{ number of downloads }</NumDownloads>
  #           <NumViews>{ number of views }</NumViews>
  #           <NumComments>{ number of comments }</NumComments>
  #           <NumFavorites>{ number of favorites }</NumFavorites>
  #           <NumSlides>{ number of slides }</NumSlides>
  #           <RelatedSlideshows>
  #             <RelatedSlideshowID rank="{ rank, where 1 is highest}">
  #             { slideshow id } </RelatedSlideshowID>
  #           </RelatedSlideshows>
  #           <PrivacyLevel>{ 0, or 1 if private }</PrivacyLevel>
  #           <FlagVisible>{ 1, or 0 if slideshow has been flagged }</FlagVisible>
  #           <ShowOnSS>{ 0, or 1 if not to be shown on Slideshare }</ShowOnSS>
  #           <SecretURL>{ 0, or 1 if secret URL is enabled }</SecretURL>
  #           <AllowEmbed>{ 0, or 1 if embeds are allowed }</AllowEmbed>
  #           <ShareWithContacts>{ 0, or 1 if set to private, but contacts can view
  #                                slideshow }
  #           </ShareWithContacts>
  #         </Slideshow>
  #
  # This kind of document is unmarshalled into an instance of Slideshow that will
  # have the following properties:
  #
  # [+slideshow_id+] The ID of the slideshow
  # [+title+] Its title
  # [+description+] Its description
  # [+status+] An instance of SlideshowStatus indicating the status of the slideshow
  # [+username+] The username of the owner of the slideshow
  # [+url+] A string representing the URL of the slideshow on slideshare
  # [+thumbnail_url+] A string representing the URL of an image that shows the cover of the slideshow
  # [+thumbnail_small_url+] A string representing the URL of an image that shows the cover of the slideshow (a smaller one)
  # [+embed+] HTML markup to embed the slideshow
  # [+created+] A DateTime object that represents when the slideshow was created
  # [+updated+] A DateTime object that represents when the slideshow was last updated
  # [+language+] A two letter code indicating the language of the slideshow (en, es, ru, ...)
  # [+format+] A string representing the format of the slideshow (pdf, ppt,...)
  # [+is_downloadable+] +true+ if the slideshow can be downloadable, +false+ otherwise
  # [+download_url+] A String rerpresenting the URL for downloading the slideshow
  # [+slideshow_type+] An instance of +SlideshowType+ indicating the type of document (document, presentation, portfolio, video...)
  # [+is_in_contest+] +true+ if the presentation is in context; +false+ otherwise
  # [+user_id+] The ID of the owner of the slideshow
  # [+external_app_user_id+] External app user identifier if the slideshow has been uploaded using an external application
  # [+external_app_id+] External app identifier if the slideshow has been uploaded using an external application
  # [+ppt_location+] The location of the ppt in the server. (although is returned by the API web method, I can't guess what can it be useful for. I'd rather use +download_url+ instead for downloading purposes)
  # [+stripped_title+] A stripped version of the title, if the title is too verbose.
  # [+tags+] A list of +Tag+ instances, each instance has the string used to tag this slideshow (+name+), the number of times this tag has been used (+times_used+) and if the tag has been previously used by its owner (+used_by_owner+)
  # [+has_audio+] +true+ if the slideshow has audio; +false+ otherwise
  # [+num_downloads+] Times the slideshow has been downloaded
  # [+num_comments+] The number of comments of this slideshow
  # [+num_views+] Times this slideshow has been viewed
  # [+num_favorites+] Times that this slideshow has been favorited
  # [+num_slides+] Number of slides
  # [+related_slideshows+] A list of +RelatedSlideshow+ instances. Each instance contains the id of the slideshow (+slideshow_id+) and its rank (+rank+)
  # [+is_private+] +true+ if the slideshow is private; +false+ otherwise
  # [+is_flagged_as_visible+] +true+ if the slideshow is flagged as visible; +false+ otherwise
  # [+is_shown_on_slideshare+] +true+ if the slideshow is shown on slideshare; +false+ otherwise
  # [+is_secret_url_enabled+] +true+ if Secret URL is enabled; +false+ otherwise
  # [+is_embed_allowed+] +true+ if the slideshow can be embedable using the code returned by +embed+; +false+ otherwise
  # [+is_only_shared_with_contacts+] +true+ if the slideshow can only be seen by its owner's contacts; +false+ if it's public
  #
  class Slideshow
    
    include Builder

    def self.extraction_rules
      {
        :slideshow_id            =>["Slideshow/ID"],
        :title                   =>["Slideshow/Title"],
        :description             =>["Slideshow/Description"],
        :status                  =>["Slideshow/Status",lambda{|node| SlideshowStatus.from_code(node.text.to_i)}],
        :username                =>["Slideshow/Username"],
        :url                     =>["Slideshow/URL"],
        :thumbnail_url           =>["Slideshow/ThumbnailURL"],
        :thumbnail_small_url     =>["Slideshow/ThumbnailSmallURL"],
        :embed                   =>["Slideshow/Embed"],
        :created                 =>["Slideshow/Created", lambda{|node| DateUtil::parse(node.text)}],
        :updated                 =>["Slideshow/Updated", lambda{|node| DateUtil::parse(node.text)}],
        :language                =>["Slideshow/Language"],
        :format                  =>["Slideshow/Format"],
        :is_downloadable         =>["Slideshow/Download", lambda{|node| node.text.to_i == 1 ? true : false}],
        :download_url            =>["Slideshow/DownloadUrl"],
        :slideshow_type          =>["Slideshow/SlideshowType",lambda{|node| SlideshowType.from_code(node.text.to_i)}],
        :is_in_contest           =>["Slideshow/InContest",lambda{|node| node.text.to_i == 1 ? true : false}],
        :user_id                 =>["Slideshow/UserID"],
        :external_app_user_id    =>["Slideshow/ExternalAppUserID"],
        :external_app_id         =>["Slideshow/ExternalAppID"],
        :ppt_location            =>["Slideshow/PPTLocation"],
        :stripped_title          =>["Slideshow/StrippedTitle"],
        :tags                    =>["Slideshow/Tags",lambda { |node| TagList.from_xml(node).items }],
        :has_audio               =>["Slideshow/Audio", lambda{|node| node.text.to_i == 1 ? true : false}],
        :num_downloads           =>["Slideshow/NumDownloads", lambda{|node| node.text.to_i}],
        :num_comments            =>["Slideshow/NumComments", lambda{|node| node.text.to_i}],
        :num_views               =>["Slideshow/NumViews", lambda{|node| node.text.to_i}],
        :num_favorites           =>["Slideshow/NumFavorites", lambda{|node| node.text.to_i}],
        :num_slides              =>["Slideshow/NumSlides", lambda{|node| node.text.to_i}],
        :related_slideshows      =>["Slideshow/RelatedSlideshows",lambda {|node| node.xpath("RelatedSlideshowID").map{|node_set| RelatedSlideshow.from_xml(node_set)}}],
        :is_private              =>["Slideshow/PrivacyLevel", lambda{|node| node.text.to_i == 1 ? true : false}],
        #SS flaw?: what does been flagged as visible exactly mean? why if it's 0 has been flagged.. and otherwise not?
        :is_flagged_as_visible   =>["Slideshow/FlagVisible", lambda{|node| node.text.to_i == 0 ? true : false}],
        #SS flaw?: why if the slideshow is shown on slideshare value of this property is 0; and if it is hidden is 1?
        :is_shown_on_slideshare  =>["Slideshow/ShowOnSS", lambda{|node| node.text.to_i == 1 ? false : true}],
        :is_secret_url_enabled   =>["Slideshow/SecretURL", lambda{|node| node.text.to_i == 1 ? true : false}],
        :is_embed_allowed        =>["Slideshow/AllowEmbed", lambda{|node| node.text.to_i == 1 ? true : false}],
        :is_only_shared_with_contacts =>["Slideshow/ShareWithContacts", lambda{|node| node.text.to_i == 1 ? true : false}],
      }
    end
  end
    
  # modelles the status of a slideshow
  #
  # it has several constants, which are instances of this same class.
  #
  # [+QUEUED+] Indicates that the slideshow has been queued for convertion
  # [+CONVERTING+] The slideshow is being converted.
  # [+CONVERTED+] The slideshow has already been converted.
  # [+CONVERSION_FAILED+] The conversion of the slideshow has been failed
  #
  # each instance has the following properties
  #
  # [+code+] A numeric code for the status (returned by the web method)
  # [+description+] A short, textual description of the status
  #
  # an extra constant is defined:
  #
  # [+STATUSES+] Is a dictionary that lets you access the status described above
  # from their numeric code.
  class SlideshowStatus
      
    attr_reader :code,:description
      
    def to_s
      "#{code} -> #{description}"
    end
      
    def self.from_code(code)
      STATUSES[code]
    end
      
    private
    def initialize(code,name)
      @code=code
      @name=name
    end
      
    QUEUED=SlideshowStatus.new(0,"queued")
    CONVERTING=SlideshowStatus.new(1,"converting")
    CONVERTED=SlideshowStatus.new(2,"converted")
    CONVERSION_FAILED=SlideshowStatus.new(3,"conversion failed")
    STATUSES={0=>QUEUED,1=>CONVERTING,2=>CONVERTED,3=>CONVERSION_FAILED}
  end
    
  # Modelles the type of a slideshow
  #
  # it has several constants, which are instances of this same class.
  #
  # [+PRESENTATION+] Indicates that the slideshow is a presentation
  # [+DOCUMENT+] The slideshow is a document
  # [+PORTFOLIO+] The slideshow is a portfolio
  # [+VIDEO+] The slideshow is a video
  #
  # each instance has the following properties
  #
  # [+code+] A numeric code for the type (returned by the web method)
  # [+description+] A short, textual description of the type
  #
  # an extra constant is defined:
  #
  # [+TYPES+] Is a dictionary that lets you access the types described above
  # from their numeric code.
  #
  class SlideshowType
      
    attr_reader :code,:description
      
    def to_s
      "#{code} -> #{description}"
    end
      
    def self.from_code(code)
      TYPES[code]
    end
      
    private
    def initialize(code,name)
      @code=code
      @name=name
    end
      
    PRESENTATION=SlideshowType.new(0,"presentation")
    DOCUMENT=SlideshowType.new(1,"document")
    PORTFOLIO=SlideshowType.new(2,"portfolio")
    VIDEO=SlideshowType.new(3,"video")
    TYPES={0=>PRESENTATION,1=>DOCUMENT,2=>PORTFOLIO,3=>VIDEO}
  end
    
  # Modelles a Tag
  #
  # The following is a the scheme of the XML that describes a Tag
  #
  #         <Tag Count="{ number of times tag has been used }" Owner="{ 1 if owner
  #                         has used the tag, else 0 }">{ tag name }
  #         </Tag>
  #
  # Each instance has the following properties:
  # [+name+] The tag name
  # [+times_used+] The number of times this tag has been used
  # [+used_by_owner+] true if the tag has been previously used by its owner, false otherwise.
  #
  # This class defines an exclusion rule on +used_by_owner+ attribute. If it is +nil+,
  # we don't include it into the instance set of properties.
  #
  class Tag

    include Builder

    def self.extraction_rules
      {
        :name           =>  ["Tag"],
        :times_used     =>  ["Tag",lambda { |nodeset| nodeset.first["Count"].nil? ? nil :  nodeset.first["Count"].to_i }],
        :used_by_owner  =>  ["Tag",lambda { |nodeset| nodeset.first["Owner"].nil? ? nil :  nodeset.first["Owner"].to_i == 1 }],
      }
    end

    def self.exclusion_rules
      {
        :used_by_owner => lambda {|value| value.nil?}
      }
    end
  end



  # Modelles a list of tags
  #
  # The following is the structure  of the XML that represents a list of tags,
  # which will be unmarshalled into an instance of this class.
  #
  #        <Tags>
  #         <Tag>
  #         ...
  #         </Tag>
  #         <Tag>
  #         ...
  #         </Tag>
  #        </Tags>
  #
  # An instance of TagList has the following properties:
  #
  # [+items+] A list of Tag instances
  #
  class TagList

    include Builder

    def self.extraction_rules
      {
        :items=>["/Tags/Tag",lambda{|nodeset| nodeset.map{|element| Tag.from_xml(element.to_s)}}]
      }
    end

    #tries to delagate unhandled requests to the items list
    def method_missing(method,*args,&b)
      if items.respond_to? method
        items.method(method).call(*args,&b)
      else
        super.method_missing(method, *args,&b)
      end
    end

  end


  # Modelles a RelatedSlideshow
  #
  #          <RelatedSlideshowID rank="{ rank, where 1 is highest}">
  #          { slideshow id } </RelatedSlideshowID>
  #
  # Instances of this class encapsulate the id of the slideshow
  # (+slideshow_id+) and its rank among the rest of the relates slideshows
  # (+rank+)
  class RelatedSlideshow

    include Builder

    def self.extraction_rules
      {
        :rank           =>   [".",lambda{|node_set| node_set.first["rank"].to_i}],
        :slideshow_id   =>   ["."]
      }
    end
  end


  #Contains utility methods for working with dates and their string representations.
  module DateUtil
    #parses a date in the following format "Sat Sep 18 08:09:00 -0500 2010"
    #returns +nil+ if the string to parse is +nil+ or empty
    def self.parse(str)
      DateTime.strptime(str, "%a %b %d %H:%M:%S %Z %Y") unless str.nil? or str.empty?
    end
  end
    
end   