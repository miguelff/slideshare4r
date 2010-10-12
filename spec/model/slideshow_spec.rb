$:.unshift File.join(File.dirname(__FILE__),'..')
require 'configuration'
require 'slideshare/model'

include Slideshare 

describe Slideshow do

  describe "from_xml providing a complete xml document" do
    before(:all) do
        xml=%q{
           <Slideshow>
            <ID>5229002</ID>
            <Title>Real time</Title>
            <Description>Transparencias de la sesi&#243;n relativa a Web en Tiempo Real  para el curso de extensi&#243;n universitaria &amp;quot;Cloud Computing. Desarrollo de Aplicaciones y Miner&#237;a Web&amp;quot;. Impartido en la Escuela Ingenier&#237;a Inform&#225;tica de Oviedo.</Description>
            <Status>2</Status>
            <Username>miguelff</Username>
            <URL>http://www.slideshare.net/miguelff/real-time</URL>
            <ThumbnailURL>http://cdn.slidesharecdn.com/realtime-100918080908-phpapp01-thumbnail</ThumbnailURL>
            <ThumbnailSmallURL>http://cdn.slidesharecdn.com/realtime-100918080908-phpapp01-thumbnail-2</ThumbnailSmallURL>
            <Embed>&lt;div style=&quot;width:425px&quot; id=&quot;__ss_5229002&quot;&gt;&lt;strong style=&quot;display:block;margin:12px 0 4px&quot;&gt;&lt;a href=&quot;http://www.slideshare.net/miguelff/real-time&quot; title=&quot;Real time&quot;&gt;Real time&lt;/a&gt;&lt;/strong&gt;&lt;object id=&quot;__sse5229002&quot; width=&quot;425&quot; height=&quot;355&quot;&gt;&lt;param name=&quot;movie&quot; value=&quot;http://static.slidesharecdn.com/swf/ssplayer2.swf?doc=realtime-100918080908-phpapp01&amp;stripped_title=real-time&amp;userName=miguelff&quot; /&gt;&lt;param name=&quot;allowFullScreen&quot; value=&quot;true&quot;/&gt;&lt;param name=&quot;allowScriptAccess&quot; value=&quot;always&quot;/&gt;&lt;embed name=&quot;__sse5229002&quot; src=&quot;http://static.slidesharecdn.com/swf/ssplayer2.swf?doc=realtime-100918080908-phpapp01&amp;stripped_title=real-time&amp;userName=miguelff&quot; type=&quot;application/x-shockwave-flash&quot; allowscriptaccess=&quot;always&quot; allowfullscreen=&quot;true&quot; width=&quot;425&quot; height=&quot;355&quot;&gt;&lt;/embed&gt;&lt;/object&gt;&lt;div style=&quot;padding:5px 0 12px&quot;&gt;View more &lt;a href=&quot;http://www.slideshare.net/&quot;&gt;presentations&lt;/a&gt; from &lt;a href=&quot;http://www.slideshare.net/miguelff&quot;&gt;Miguel Fern&#225;ndez&lt;/a&gt;.&lt;/div&gt;&lt;/div&gt;</Embed>
            <Created>Sat Sep 18 08:09:00 -0500 2010</Created>
            <Updated>Sat Sep 18 08:20:13 -0500 2010</Updated>
            <Language>en</Language>
            <Format>pdf</Format>
            <Download>1</Download>
            <DownloadUrl>http://s3.amazonaws.com/ppt-download/realtime-100918080908-phpapp01.pdf?Signature=syPncW5oyWSnrqdFd7NggFWI%2FpU%3D&amp;Expires=1286447642&amp;AWSAccessKeyId=AKIAJLJT267DEGKZDHEQ</DownloadUrl>
            <SlideshowType>0</SlideshowType>
            <InContest>0</InContest>
            <UserID>4689517</UserID>
            <PPTLocation>realtime-100918080908-phpapp01</PPTLocation>
            <StrippedTitle>real-time</StrippedTitle>
            <Tags>
              <Tag Owner="1" Count="1">tiempo real</Tag>
              <Tag Owner="1" Count="1">ajax</Tag>
              <Tag Owner="1" Count="1">websockets</Tag>
              <Tag Owner="1" Count="1">real time</Tag>
              <Tag Owner="1" Count="1">comet</Tag>
              <Tag Owner="1" Count="1">xmpp</Tag>
            </Tags>
            <Audio>0</Audio>
            <NumDownloads>0</NumDownloads>
            <NumViews>35</NumViews>
            <NumComments>0</NumComments>
            <NumFavorites>0</NumFavorites>
            <NumSlides>44</NumSlides>
            <RelatedSlideshows>
              <RelatedSlideshowID rank="3">89455</RelatedSlideshowID>
              <RelatedSlideshowID rank="4">89460</RelatedSlideshowID>
              <RelatedSlideshowID rank="5">442132</RelatedSlideshowID>
              <RelatedSlideshowID rank="6">452319</RelatedSlideshowID>
              <RelatedSlideshowID rank="1">664916</RelatedSlideshowID>
              <RelatedSlideshowID rank="7">702737</RelatedSlideshowID>
              <RelatedSlideshowID rank="2">782057</RelatedSlideshowID>
              <RelatedSlideshowID rank="8">954230</RelatedSlideshowID>
              <RelatedSlideshowID rank="9">1135870</RelatedSlideshowID>
              <RelatedSlideshowID rank="10">1151262</RelatedSlideshowID>
            </RelatedSlideshows>
            <PrivacyLevel>0</PrivacyLevel>
            <FlagVisible>1</FlagVisible>
            <ShowOnSS>0</ShowOnSS>
            <SecretURL>0</SecretURL>
            <AllowEmbed>0</AllowEmbed>
            <ShareWithContacts>0</ShareWithContacts>
          </Slideshow>
          }
      @slideshow=Slideshow.from_xml xml
    end

    it "should set the proper value for slideshow_id" do
      @slideshow.slideshow_id.should == "5229002"
    end

    it "should set the proper value for title" do
      @slideshow.title.should == "Real time"
    end

    it "should set the proper value for status" do
      @slideshow.status.should equal(SlideshowStatus::CONVERTED)
    end

    it "should set the proper value for username" do
      @slideshow.username.should == "miguelff"
    end

    it "should set the proper value for url" do
      @slideshow.url.should == "http://www.slideshare.net/miguelff/real-time"
    end

    it "should set the proper value for thumbnail_url" do
      @slideshow.thumbnail_url.should == "http://cdn.slidesharecdn.com/realtime-100918080908-phpapp01-thumbnail"
    end

    it "should set the proper value for thumbnail_small_url" do
      @slideshow.thumbnail_small_url.should == "http://cdn.slidesharecdn.com/realtime-100918080908-phpapp01-thumbnail-2"
    end

    it "should set the proper value for embed" do
      @slideshow.embed.size.should > 255
    end

    it "should set the proper value for created" do
      @slideshow.created.should == DateTime.parse("2010-09-18T08:09:00-05:00")
    end

    it "should set the proper value for updated" do
      @slideshow.updated.should == DateTime.parse("2010-09-18T08:20:13-05:00")
    end

    it "should set the proper value for language" do
      @slideshow.language.should == "en"
    end

    it "should set the proper value for format" do
      @slideshow.format.should == "pdf"
    end

    it "should set the proper value for is_downloadable" do
      @slideshow.is_downloadable.should be_true
    end

    it "should set the proper value for slideshow_type" do
      @slideshow.slideshow_type.should equal(SlideshowType::PRESENTATION)
    end

    it "should set the proper value for is_in_contest" do
       @slideshow.is_in_contest.should be_false
    end

    it "should set the proper value for tags" do
      @slideshow.tags.count.should == 6
      @slideshow.tags.first.times_used.should == 1
      @slideshow.tags.first.name.should == "tiempo real"
      @slideshow.tags.first.used_by_owner.should be_true
    end

    it "should set the proper value for has_audio" do
      @slideshow.has_audio.should be_false
    end

    it "should set the proper value for num_downloads" do
      @slideshow.num_downloads.should == 0
    end

    it "should set the proper value for num_views" do
      @slideshow.num_views.should == 35
    end

    it "should set the proper value for num_comments" do
      @slideshow.num_comments.should == 0
    end

    it "should set the proper value for num_slides" do
      @slideshow.num_slides.should == 44
    end

    it "should set the proper value for num_favorites" do
      @slideshow.num_favorites.should == 0
    end

    it "should set the proper value for related_slideshows" do
      @slideshow.related_slideshows.count.should == 10
      @slideshow.related_slideshows.first.rank == 3
      @slideshow.related_slideshows.first.slideshow_id == "89455"
    end

    it "should set the proper value for is_private" do
      @slideshow.is_private.should be_false
    end

    it "should set the proper value for is_flagged_as_visible" do
      @slideshow.is_flagged_as_visible.should be_false
    end

    it "should set the proper value for is_shown_on_slideshare" do
      @slideshow.is_shown_on_slideshare.should be_true
    end

    it "should set the proper value for is_secret_url_enabled" do
      @slideshow.is_secret_url_enabled.should be_false
    end

    it "should set the proper value for is_embed_allowed" do
      @slideshow.is_embed_allowed.should be_false
    end

    it "should set the proper value for is_only_shared_with_contacts" do
      @slideshow.is_embed_allowed.should be_false
    end
  end
  
  it "doesn't fail if document contains no data" do
    xml=%q{
     <Slideshow/>
    }
    slideshow=Slideshow.from_xml xml
    slideshow.methods(false).count.should == Slideshow.extraction_rules.size*2
  end

  
end
