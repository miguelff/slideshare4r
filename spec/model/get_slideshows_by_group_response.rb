$:.unshift File.join(File.dirname(__FILE__),'..')
require 'configuration'
require 'slideshare/model'

include Slideshare

describe GetSlideshowsByGroupResponse do

  describe "from_xml providing a complete an xml document with just one slideshow definition" do
    before(:all) do
        xml=%q{
          <Group>
           <Count>12344</Count>
           <Name>group</Name>
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
        </Group>
          }
      @response=GetSlideshowsByGroupResponse.from_xml xml
    end

    it "invoking :slideshows returns a list with one slideshow " do
      @response.slideshows.count.should == 1
    end

    it "slideshows single item is an Slideshow " do
      @response.slideshows.first.should be_kind_of Slideshow
    end


  end

    describe "from_xml providing a complete an xml document with two slideshow definition" do
    before(:all) do
        xml=%q{
           <Group>
           <Count>12344</Count>
           <Name>group</Name>
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
        </Group>
          }
      @response=GetSlideshowsByGroupResponse.from_xml xml
    end

    it "invoking :slideshows returns a list with two slideshows " do
      @response.slideshows.count.should == 2
    end

    it "each item is a Slideshow " do
      @response.slideshows.each do |item|
        item.should be_kind_of Slideshow
      end
    end

    it "must retrieve the number of results" do
       @response.total_number_of_results.should == 12344
    end

     it "must retrieve the name of the tag searched of results" do
       @response.group_searched.should == "group"
    end
  end

  it "doesn't fail if document contains no Slideshow definitions" do
    xml=%q{
     <Tag/>
    }
    slideshow=GetSlideshowsByTagResponse.from_xml xml
    slideshow.methods(false).count.should == GetSlideshowsByTagResponse.extraction_rules.size*2
  end


end
