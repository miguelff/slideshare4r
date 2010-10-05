
#
# API façade. Provides a single entry point to every API method.
#
class Slideshare

  #Initializes a new instance of the API Façade
  #You must provide your api_key. If you don't have one, you have to apply
  #for one at http://www.slideshare.net/developers/applyforapi
  #
  #Optionally you have to provide some arguments.
  #login
  def initialize(api_key, properties={})
    raise ArgumentError.new "api_key must be a String and it's #{api_key}" unless api_key.kind_of? String
    default_properties={
      :username=>nil,
      :password=>nil
    }
    properties=default_properties.merge properties
    @api_key=api_key
    @username=properties[:username]
    @password=properties[:password]
  end
  
end
