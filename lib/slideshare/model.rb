require 'rubygems'
require 'nokogiri'
require 'date'

module Slideshare 
    
  
  # Classes that include this module, extend its eigenclass by adding
  # from_xml(xml_str) method, which builds a new instance of the
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
    # The information to gather from the XML document is pointed by a dictionary
    # returned by self.extraction_rules method, which is defined in each of the classes
    # that include the module.
    #
    # This dictionary contains the name of the instance property as the key,
    # and a list indicating how to extract it from the XML as the value. The latter
    # must have at least one first element, which is the XPATH expression that points
    # to the xml that encloses the value of the property. An optional second parameter
    # is a block that receives one paremeter (the XML node pointed by the expression)
    # and returns the information to set on the property. If not provided, the block will
    # get the inner text of the node.
    #
    # As an example, imagine the following class:
    #
    # class Slideshow
    #  include Builder
    #
    #  def self.extraction_rules
    #    {
    #      :id=>["Slideshow/ID"],
    #      :title=>["Slideshow/Title",lambda{|x| x.value.upcase}]
    #    }
    #  end
    # end
    #
    #
    # and the following xml document
    #
    # xml_str=%q{
    # <Slideshow>
    #  <ID>foo</ID>
    #  <Title>bar/Title>
    # </Slideshow>
    # }
    #
    # if we make this call:
    #
    # Slideshow.from_xml(xml_str)
    #
    # we will obtain something like
    #
    # <Slideshow:0x1014e11f8 @id="foo", @title="BAR">
    #
    # this instance will also have accessor methods for both id, and title.
    #
    def from_xml(xml_doc)
      instance=self.new
      xml_doc  = Nokogiri::XML(xml_doc.to_s) unless xml_doc.kind_of? Nokogiri::XML::Node
      self.extraction_rules.each_pair do |attribute,rule|
        path=rule[0]
        extraction_predicate=rule[1] ||= lambda{|x| x.text}
        instance.instance_variable_set("@#{attribute}",extraction_predicate.call(xml_doc.xpath(path)))
        instance.instance_eval "def #{attribute}; @#{attribute}; end"
        instance.instance_eval "def #{attribute}=(value); @#{attribute}=value;end"
      end
      instance
    end
  end

  # Modelles the response of API#get_slideshows_by_group method
  #
  # The following is the structure  of the XML returned by the API web method,
  # which will be unmarshalled into an instance of this class.
  #
  #<Group>
  #<Name>{ Tag Name }</Name>
  #<Count>{ Number of Slideshows }</Count>
  #<Slideshow>
  #  { as in get_slideshow }
  #</Slideshow>
  #...
  #</Group>
  #
  # An instance of GetSlideshowsByGroupResponse has the following properties:
  #
  # slideshows => A list of Slideshow instances tagged with the string used to make the search
  # total_number_of_results => The total number of slideshows on slideshare that are tagged with the string searched
  # group_searched => the string used to search a list of the slideshows tagged with it.
  #
  class GetSlideshowsByGroupResponse
    include Builder

    def self.extraction_rules
      {
        :slideshows              =>["//Slideshow",lambda{|nodeset| nodeset.map{|element| Slideshow.from_xml(element)}}],
        :total_number_of_results => ["/Group/Count",lambda{|node| node.text.to_i}],
        :group_searched          => ["/Group/Name"]
      }
    end
  end

  # Modelles the response of API#get_slideshows_by_tag method
  #
  # The following is the structure  of the XML returned by the API web method,
  # which will be unmarshalled into an instance of this class.
  #
  #<Tag>
  #<Name>{ Tag Name }</Name>
  #<Count>{ Number of Slideshows }</Count>
  #<Slideshow>
  #  { as in get_slideshow }
  #</Slideshow>
  #...
  #</Tag>
  #
  # An instance of GetSlideshowsByTagResponse has the following properties:
  #
  # slideshows => A list of Slideshow instances tagged with the string used to make the search
  # total_number_of_results => The total number of slideshows on slideshare that are tagged with the string searched
  # tag_searched => the string used to search a list of the slideshows tagged with it.
  #
  class GetSlideshowsByTagResponse
    include Builder

    def self.extraction_rules
      {
        :slideshows               =>["//Slideshow",lambda{|nodeset| nodeset.map{|element| Slideshow.from_xml(element)}}],
        :total_number_of_results  => ["/Tag/Count",lambda{|node| node.text.to_i}],
        :tag_searched             => ["/Tag/Name"]
      }
    end
  end

  # Modelles the response of API#get_slideshows_by_user method
  #
  # The following is the structure  of the XML returned by the API web method,
  # which will be unmarshalled into an instance of this class.
  #
  #<User>
  #<Name>{ username_for }</Name>
  #<Count>{ Number of Slideshows }</Count>
  #<Slideshow>
  #  { as in get_slideshow }
  #</Slideshow>
  #...
  #</Group>
  #
  # An instance of GetSlideshowsByUserResponse has the following properties:
  #
  # slideshows => A list of Slideshow instances that belong to the user
  # total_number_of_results => The total number of slideshows on slideshare that belong to the user
  # user_searched => the string used to search a list of the slideshows tagged with it.
  #
  class GetSlideshowsByUserResponse
    include Builder

    def self.extraction_rules
      {
        :slideshows              => ["//Slideshow",lambda{|nodeset| nodeset.map{|element| Slideshow.from_xml(element)}}],
        :total_number_of_results => ["/User/Count",lambda{|node| node.text.to_i}],
        :user_searched          =>  ["/User/Name"]
      }
    end
  end




  # Modelles a Group
  #
  # The following is the structure  of the XML returned by the API web method,
  # which will be unmarshalled into an instance of this class.
  #
  #  <Group>
  #  <Name>{ Group Name }</Name>
  #  <NumPosts>{ Number of Posts }</NumPosts>
  #  <NumSlideshows>{ Number of Slideshows }</NumSlideshows>
  #  <NumMembers>{ Number of Members }</NumMembers>
  #  <Created>{ Created date }</Created>
  #  <QueryName>{ Name used for querying (get_slideshows_by_group, etc) }</QueryName>
  #  <URL>{ Group URL }</URL>
  # <Group>
  #
  # An instance of group has the following properties:
  #
  # :name => the group name
  # :num_posts => number of posts published on this group
  # :num_slideshows => number of slideshows belonging to this group
  # :num_members => number of members of this groups
  # :created => a DateTime object indicating when the group was created
  # :query_name => a string used to make other queries (get_slideshows_by_group, etc)
  # :url => url of the group
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
  #<Groups>
  #<Group>
  #...
  #</Group>
  #<Group>
  #...
  #</Group>
  #</Groups>
  #
  # An instance of GroupList has the following properties:
  #
  # items => a list of group instances
  #
  class GroupList
    include Builder

    def self.extraction_rules
      {
        :items =>["//Group",lambda{|nodeset| nodeset.map{|element| Group.from_xml(element)}}],
      }
    end
    
  end
   
  
  # Modelles a Slideshow
  #
  # See http://www.slideshare.net/developers/documentation#get_slideshow
  #
  # The following is a the structure of the XML that describes a Slideshow
  #
  # <Slideshow>
  #   <ID>{ slideshow id }</ID>
  #   <Title>{ slideshow title }</Title>
  #   <Description>{ slideshow description }</Description>
  #   <Status>{ 0 if queued for conversion, 1 if converting, 2 if converted,
  #             3 if conversion failed }
  #   </Status>
  #   <Username>{ username }</Username>
  #   <URL>{ web permalink }</URL>
  #   <ThumbnailURL>{ thumbnail URL }</ThumbnailURL>
  #   <ThumbnailSmallURL>{ URL of smaller thumbnail }</ThumbnailSmallURL>
  #   <Embed>{ embed code }</Embed>
  #   <Created>{ date slideshow created }</Created>
  #   <Updated>{ date slideshow was last update }</Updated>
  #   <Language>{ language, as specified by two-letter code }</Language>
  #   <Format>ppt (or pdf, pps, odp, doc, pot, txt, rdf) </Format>
  #   <Download>{ 1 if available to download, else 0 }</Download>
  #   <DownloadUrl>{ returns if available to download }</DownloadUrl>
  #   <SlideshowType>{ 0 if presentation, 1 if document, 2 if a portfolio,
  #     3 if video }</SlideshowType>
  #   <InContest>{ 1 if part of a contest, 0 if not }</Download>
  #
  #   <UserID>{ userID }</UserID>
  #   <ExternalAppUserID>{ ExternalAppUserID if uploaded using an
  #          external app }</ExternalAppUserID>
  #   <ExternalAppID>{ ExternalAppID for the external app }</ExternalAppID>
  #   <PPTLocation>{ PPTLocation }</ExternalAppUserID>
  #   <StrippedTitle>{ Stripped Title }</StrippedTitle>
  #   <Tags>
  #   <Tag Count="{ number of times tag has been used }" Owner="{ 1 if owner
  #                 has used the tag, else 0 }">{ tag name }
  #   </Tag>
  #   </Tags>
  #   <Audio>{ 0, or 1 if the slideshow contains audio }</Audio>
  #   <NumDownloads>{ number of downloads }</NumDownloads>
  #   <NumViews>{ number of views }</NumViews>
  #   <NumComments>{ number of comments }</NumComments>
  #   <NumFavorites>{ number of favorites }</NumFavorites>
  #   <NumSlides>{ number of slides }</NumSlides>
  #   <RelatedSlideshows>
  #     <RelatedSlideshowID rank="{ rank, where 1 is highest}">
  #     { slideshow id } </RelatedSlideshowID>
  #   </RelatedSlideshows>
  #   <PrivacyLevel>{ 0, or 1 if private }</PrivacyLevel>
  #   <FlagVisible>{ 1, or 0 if slideshow has been flagged }</FlagVisible>
  #   <ShowOnSS>{ 0, or 1 if not to be shown on Slideshare }</ShowOnSS>
  #   <SecretURL>{ 0, or 1 if secret URL is enabled }</SecretURL>
  #   <AllowEmbed>{ 0, or 1 if embeds are allowed }</AllowEmbed>
  #   <ShareWithContacts>{ 0, or 1 if set to private, but contacts can view
  #                        slideshow }
  #   </ShareWithContacts>
  # </Slideshow>
  #
  # This kind of document is unmarshalled into an instance of Slideshow that will
  # have the following properties:
  #
  # slideshow_id  => the ID of the slideshow
  # title => its title
  # description => its description
  # status => an instance of SlideshowStatus indicating the status of the slideshow
  # username => the username of the owner of the slideshow
  # url => a string representing the URL of the slideshow on slideshare
  # thumbnail_url => a string representing the URL of an image that shows the cover of the slideshow
  # thumbnail_small_url => a string representing the URL of an image that shows the cover of the slideshow (a smaller one)
  # embed => HTML markup to embed the slideshow
  # created => a DateTime object that represents when the slideshow was created
  # updated => a DateTime object that represents when the slideshow was last updated
  # language => a two letter code indicating the language of the slideshow (en, es, ru, ...)
  # format => a string representing the format of the slideshow (pdf, ppt,...)
  # is_downloadable => true if the slideshow can be downloadable, false otherwise
  # download_url => a String rerpresenting the URL for downloading the slideshow
  # slideshow_type => an instance of SlideshowType indicating the type of document (document, presentation, portfolio, video...)
  # is_in_contest => true if the presentation is in context; false otherwise
  # user_id => the ID of the owner of the slideshow
  # external_app_user_id => external app user identifier if the slideshow has been uploaded using an external application
  # external_app_id => external app identifier if the slideshow has been uploaded using an external application
  # ppt_location => the location of the ppt in the server. (although is returned by the API web method, I can't guess what can it be useful for. I'd rather use download_url for downloading purposes instead)
  # stripped_title => a stripped version of the title, if the title is too verbose.
  # tags => a list of Tag instances, each instance has the string used to tag this slideshow (:name), the number of times this tag has been used (:times_used) and if the tag has been previously used by its owner (:used_by_owner)
  # has_audio => true if the slideshow has audio; false otherwise
  # num_downloads => times the slideshow has been downloaded
  # num_comments => the number of comments of this slideshow
  # num_views => times this slideshow has been viewed
  # num_favorites => times that this slideshow has been favorited
  # num_slides => number of slides
  # related_slideshows => a list of RelatedSlideshow instance. Each instance contains the id of the slideshow (:slideshow_id) and the rank (:rank)
  # is_private => true if the slideshow is private; false otherwise
  # is_flagged_as_visible => true if the slideshow is flagged as visible; false otherwise
  # is_shown_on_slideshare => true if the slideshow is shown on slideshare; false otherwise
  # is_secret_url_enabled => true if Secret URL is enabled; false otherwise
  # is_embed_allowed => true if the slideshow can be embedable using the code returned by :embed; false otherwise
  # is_only_shared_with_contacts => true if the slideshow can only be seen by its owner's contacts; false if it's public
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
        :tags                    =>["Slideshow/Tags",lambda { |node| node.xpath("Tag").map { |tag_node| Tag.from_xml(tag_node) }}],
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
  # QUEUED => indicates that the slideshow has been queued for convertion
  # CONVERTING => the slideshow is being converted.
  # CONVERTED => the slideshow has already been converted.
  # CONVERSION_FAILED => the conversion of the slideshow has been failed
  #
  # each instance has the following properties
  #
  # code => a numeric code for the status (returned by the web method)
  # description => a short, textual description of the status
  #
  # an extra constant is defined:
  #
  # STATUSES => is a dictionary that lets you access the status described above
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
    
  # modelles the type of a slideshow
  #
  # it has several constants, which are instances of this same class.
  #
  # PRESENTATION => indicates that the slideshow is a presentation
  # DOCUMENT => the slideshow is a document
  # PORTFOLIO => the slideshow is a portfolio
  # VIDEO => the slideshow is a video
  #
  # each instance has the following properties
  #
  # code => a numeric code for the type (returned by the web method)
  # description => a short, textual description of the type
  #
  # an extra constant is defined:
  #
  # TYPES => is a dictionary that lets you access the types described above
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
  #    <Tag Count="{ number of times tag has been used }" Owner="{ 1 if owner
  #                 has used the tag, else 0 }">{ tag name }
  #    </Tag>
  #
  # Each instance has the string used to tag this slideshow (:name),
  # the number of times this tag has been used (:times_used)
  # and if the tag has been previously used by its owner (:used_by_owner)
  class Tag
      
    include Builder
      
    def self.extraction_rules
      {
        :times_used     =>  [".",lambda { |node_set| node_set.first["Count"].to_i }],
        :used_by_owner  =>  [".",lambda { |node_set| node_set.first["Owner"].to_i == 1 ? true : false}],
        :name           =>  ["."]
      }
    end
  end

  # Modelles a RelatedSlideshow
  #
  #  <RelatedSlideshowID rank="{ rank, where 1 is highest}">
  #     { slideshow id } </RelatedSlideshowID>
  #
  # Instances of this class encapsulate the id of the slideshow
  # (:slideshow_id) and its rank among the rest of the relates slideshows
  # (:rank)
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
    #returns nil if the string to parse is nil or empty
    def self.parse(str)
      DateTime.strptime(str, "%a %b %d %H:%M:%S %Z %Y") unless str.nil? or str.empty?
    end
  end
    
end   