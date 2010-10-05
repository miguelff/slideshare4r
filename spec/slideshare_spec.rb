# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'slideshare'

describe Slideshare do
  it "should initialize when every required argument is provided" do
    Slideshare.new "foo"
  end

   it "should failed initializitaion when not every required argument is provided" do
    lambda{Slideshare.new}.should raise_error
  end

   it "should failed initializitaion when api_key is nil" do
    lambda{Slideshare.new nil}.should raise_error
  end

   it "should failed initializitaion when api_key is not a string " do
    lambda{Slideshare.new 4}.should raise_error
  end
end

