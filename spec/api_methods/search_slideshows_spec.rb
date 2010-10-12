$:.unshift File.join(File.dirname(__FILE__),'..')
require 'slideshare'
require 'configuration'

include Slideshare

describe "API#search_slideshows" do
  before(:each) do
    @api=API.new Config::API_KEY, Config::SHARED_SECRET, :proxy_host=>Config::PROXY_HOST, :proxy_port=>Config::PROXY_PORT, :protocol=>:http
  end

  it "should raise an error if no arguments provided" do
    lambda{@api.search_slideshows}.should raise_error(ArgumentError)
  end

  it "should raise an error if :q is not provided" do
    lambda{@api.search_slideshows :t=>nil}.should raise_error(ArgumentError)
  end

  it "should raise an error if :q is not a string" do
    lambda{@api.search_slideshows :q=>nil}.should raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>3}.should raise_error(ArgumentError)
  end

  it "should raise an error if :page is not a positive_integer" do
    lambda{@api.search_slideshows :q=>"art", :page=>-1}.should raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :page=>0}.should raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :page=>"wrong"}.should raise_error(ArgumentError)
  end

  it "should not raise an error if :page is a positive_integer" do
    lambda{@api.search_slideshows :q=>"art", :page=>1}.should_not raise_error(ArgumentError)
  end

  it "should raise an error if items_per_page is not a positive integer" do
    lambda{@api.search_slideshows :q=>"art", :items_per_page=>-1}.should raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :items_per_page=>0}.should raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :items_per_page=>"wrong"}.should raise_error(ArgumentError)
  end

  it "should not raise an error if :items_per_page is a positive_integer" do
    lambda{@api.search_slideshows :q=>"art", :items_per_page=>1}.should_not raise_error(ArgumentError)
  end

  it "should raise an error if :lang is not a valid language code" do
    lambda{@api.search_slideshows :q=>"art", :lang=>"en"}.should raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :lang=>:foo}.should raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :lang=>nil}.should raise_error(ArgumentError)
  end

  it "should not raise an error if :lang is a valid language code" do
    lambda{@api.search_slideshows :q=>"art", :lang=>:en}.should_not raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :lang=>:"**"}.should_not raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :lang=>:"!!"}.should_not raise_error(ArgumentError)
  end

  it "should raise an error if :sort is not a valid sort order" do
    lambda{@api.search_slideshows :q=>"art", :sort=>"relevance"}.should raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :sort=>:foo}.should raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :sort=>nil}.should raise_error(ArgumentError)
  end

  it "should not raise an error if :sort is a valid sort order" do
    lambda{@api.search_slideshows :q=>"art", :sort=>:relevance}.should_not raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :sort=>:mostviewed}.should_not raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :sort=>:mostdownloaded}.should_not raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :sort=>:latest}.should_not raise_error(ArgumentError)
  end

  it "should raise an error if :upload_date is not a valid upload date" do
    lambda{@api.search_slideshows :q=>"art", :upload_date=>"week"}.should raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :upload_date=>:foo}.should raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :upload_date=>nil}.should raise_error(ArgumentError)
  end

  it "should not raise an error if :upload_date is a valid upload date" do
    lambda{@api.search_slideshows :q=>"art", :upload_date=>:any}.should_not raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :upload_date=>:week}.should_not raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :upload_date=>:month}.should_not raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :upload_date=>:year}.should_not raise_error(ArgumentError)
  end

  it "should raise an error if :search_in_tags_only is not true or false" do
    lambda{@api.search_slideshows :q=>"art", :search_in_tags_only=>:foo}.should raise_error(ArgumentError)
  end

  it "should not raise an error if :search_in_tags_only is true or false" do
    lambda{@api.search_slideshows :q=>"art", :search_in_tags_only=>true}.should_not raise_error(ArgumentError)
  end

  it "should raise an error if :restrict_to_downloadables is not true or false" do
    lambda{@api.search_slideshows :q=>"art", :restrict_to_downloadables=>:foo}.should raise_error(ArgumentError)
  end

  it "should not raise an error if :restrict_to_downloadables is true or false" do
    lambda{@api.search_slideshows :q=>"art", :restrict_to_downloadables=>true}.should_not raise_error(ArgumentError)
  end

  it "should raise an error if :file_format is not a valid file format" do
    lambda{@api.search_slideshows :q=>"art", :file_format=>"pdf"}.should raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :file_format=>:foo}.should raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :file_format=>nil}.should raise_error(ArgumentError)
  end

  it "should not raise an error if :file_format is a valid file format" do
    lambda{@api.search_slideshows :q=>"art", :file_format=>:all}.should_not raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :file_format=>:pdf}.should_not raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :file_format=>:ppt}.should_not raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :file_format=>:odp}.should_not raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :file_format=>:pps}.should_not raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :file_format=>:pot}.should_not raise_error(ArgumentError)
  end

  it "should raise an error if :file_type is not a valid file type" do
    lambda{@api.search_slideshows :q=>"art", :file_type=>"presentation"}.should raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :file_type=>:foo}.should raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :file_type=>nil}.should raise_error(ArgumentError)
  end

  it "should not raise an error if :file_type is a valid file type" do
    lambda{@api.search_slideshows :q=>"art", :file_type=>:all}.should_not raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :file_type=>:presentations}.should_not raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :file_type=>:documents}.should_not raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :file_type=>:webinars}.should_not raise_error(ArgumentError)
    lambda{@api.search_slideshows :q=>"art", :file_type=>:videos}.should_not raise_error(ArgumentError)
  end

  it "should raise an error if :restrict_to_cc is not true or false" do
    lambda{@api.search_slideshows :q=>"art", :restrict_to_cc=>:foo}.should raise_error(ArgumentError)
  end

  it "should not raise an error if :restrict_to_cc is true or false" do
    lambda{@api.search_slideshows :q=>"art", :restrict_to_cc=>true}.should_not raise_error(ArgumentError)
  end

  it "should raise an error if :restrict_to_cc_adapt is not true or false" do
    lambda{@api.search_slideshows :q=>"art", :restrict_to_cc_adapt=>:foo}.should raise_error(ArgumentError)
  end

  it "should not raise an error if :restrict_to_cc_adapt is true or false" do
    lambda{@api.search_slideshows :q=>"art", :restrict_to_cc_adapt=>true}.should_not raise_error(ArgumentError)
  end

  it "should raise an error if :restrict_to_cc_commercial is not true or false" do
    lambda{@api.search_slideshows :q=>"art", :restrict_to_cc_commercial=>:foo}.should raise_error(ArgumentError)
  end

  it "should not raise an error if :restrict_to_cc_commercial is true or false" do
    lambda{@api.search_slideshows :q=>"art", :restrict_to_cc_commercial=>true}.should_not raise_error(ArgumentError)
  end

  it "should raise an error if :detailed is not true or false" do
    lambda{@api.search_slideshows :q=>"art", :detailed=>:foo}.should raise_error(ArgumentError)
  end

  it "should not raise an error if :detailed is true or false" do
    lambda{@api.search_slideshows :q=>"art", :detailed=>true}.should_not raise_error(ArgumentError)
  end

  it "should complete the request without giving any error" do
    search_results = @api.search_slideshows :q => "art",
      :page => 1,
      :items_per_page => 12,
      :lang =>:"**",
      :sort =>:mostviewed,
      :upload_date=>:any,
      :search_in_tags_only => true,
      :restrict_to_downloadables=>true,
      :file_format=>:ppt,
      :file_type=>:presentations,
      :restrict_to_cc => true,
      :restrict_to_cc_adapt => true,
      :restrict_to_cc_commercial => true,
      :detailed => false

    search_results.should_not be_nil
    search_results.items.should be_kind_of Array
    search_results.items.should_not be_empty
    search_results.query.should be_kind_of String
    search_results.total_number_of_results.should > 0
    search_results.result_offset.should > 0
  end

  it "a more restrictive request should retrieve less results then other less restrictive" do
    less_restrictive = @api.search_slideshows :q => "art"
    more_restrictive = @api.search_slideshows :q => "art",
      :page => 1,
      :items_per_page => 12,
      :lang =>:"**",
      :sort =>:mostviewed,
      :upload_date=>:any,
      :search_in_tags_only => true,
      :restrict_to_downloadables=>true,
      :file_format=>:ppt,
      :file_type=>:presentations,
      :restrict_to_cc => true,
      :restrict_to_cc_adapt => true,
      :restrict_to_cc_commercial => true,
      :detailed => false
    less_restrictive.total_number_of_results.should > more_restrictive.total_number_of_results
  end

end