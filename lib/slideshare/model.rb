require 'rubygems'
require 'nokogiri'
require 'date'

module Slideshare 
    
  #
  # Classes that include this module, extend its eigenclass interface
  # by adding from_xml(xml_str) method, which builds a new instance of the
  # class extended by unmarshalling the XML document provided.
  #
  module Builder
      
    # When clases include this module, they
    # extend they functionality with this
    # module's instance methods
    def self.included(base)
      base.extend(self)
    end

      
 
    # Takes an XML document as a string, and extracts certain information from it
    # adding new properties to the instance being built on the fly.
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
    def from_xml(xml_str)
      instance=self.new
      xml_doc  = Nokogiri::XML(xml_str)
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
   
  
  # Modelles a Slideshow
  #
  # see http://www.slideshare.net/developers/documentation#get_slideshow
  #
  # The following is a the scheme of the XML that describes a Slideshow
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
  # This document is unmarshalled, using the following rules
  # returned by Slideshow.extraction_rules method
  # (see Builder::from_xml for more information)
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
        :tags                    =>["Slideshow/Tags",lambda {|node| node.xpath("Tag").map{|tag_node| Tag.from_xml(tag_node.to_xml)}}],
        :has_audio               =>["Slideshow/Audio", lambda{|node| node.text.to_i == 1 ? true : false}],
        :num_downloads           =>["Slideshow/NumDownloads", lambda{|node| node.text.to_i}],
        :num_comments            =>["Slideshow/NumComments", lambda{|node| node.text.to_i}],
        :num_views               =>["Slideshow/NumViews", lambda{|node| node.text.to_i}],
        :num_favorites           =>["Slideshow/NumFavorites", lambda{|node| node.text.to_i}],
        :num_slides              =>["Slideshow/NumSlides", lambda{|node| node.text.to_i}],
        :related_slideshows      =>["Slideshow/RelatedSlideshows",lambda {|node| node.xpath("RelatedSlideshowID").map{|tag_node| RelatedSlideshow.from_xml(tag_node.to_xml)}}],
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
    
  # modelles the status of a slideshow
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
  #   </Tag>
  class Tag
      
    include Builder
      
    def self.extraction_rules
      {
        :times_used     =>  ["Tag",lambda{|node| node.attr("Count").value.to_i}],
        :used_by_owner  =>  ["Tag",lambda{|node| node.attr("Owner").value.to_i == 1 ? true : false}],
        :name           =>  ["Tag"]
      }
    end
  end

  # Modelles a RelatedSlideshow
  #
  #  <RelatedSlideshowID rank="{ rank, where 1 is highest}">
  #     { slideshow id } </RelatedSlideshowID>
  class RelatedSlideshow

    include Builder

    def self.extraction_rules
      {
        :rank =>   ["RelatedSlideshowID",lambda{|node| node.attr("rank").value.to_i}],
        :slideshow_id   =>   ["RelatedSlideshowID"]
      }
    end
  end


  module DateUtil
    #parses a date in the following format "Sat Sep 18 08:09:00 -0500 2010"
    #returns nil if the string to parse is nil or empty
    def self.parse(str)
      DateTime.strptime(str, "%a %b %d %H:%M:%S %Z %Y") unless str.nil? or str.empty?
    end
  end
    
end   