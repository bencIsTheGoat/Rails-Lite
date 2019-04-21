require 'json'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    #debugger
    @hash = {}
    @cookie = req.cookies['_rails_lite_app']
    if @cookie
      @json_hash = JSON.parse(@cookie)
    else
      @json_hash = {}
    end
    
  end

  def [](key)
    @json_hash[key]
  end

  def []=(key, val)
    @json_hash[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    @serialize_hash = @json_hash.to_json
    res.set_cookie('_rails_lite_app', @serialize_hash)
  end
end
