# Rails Lite
### Contributors 
 * ### Ben Cutler bcutler94@gmail.com
 * ### Mark Rodriguez mrxkvncnt@gmail.com
 
### Overview

Comprehensive meta-programming project that mimics the functionality of the Ruby on Rails framework

### Features

#### ActionController::Base methods

* The code below populates the HTTP response with content and sets the content type to the given type of response, making sure that a double render does not occur

```ruby
def render_content(content, content_type)
    unless already_built_response?
      @res.body = [content]
      @res['Content-Type'] = content_type
      @already_built_response = true
      self.session.store_session(@res)
    else
      raise
    end
  end
```

* The code below uses ERB and binding to evaluate templates and pass the rendered HTML to render_content

```ruby
 def render(template_name)
    view_folder = self.class.to_s.underscore
    view = File.dirname(view_folder)
    text = File.read("views/#{view_folder}/#{template_name}.html.erb")
    erb = ERB.new(text).result(binding)
    render_content(erb, 'text/html')
  end
```

#### Session class

* When initialized, finds the cookie for the app and serializes the cookie into hash

```ruby
class Session
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

  def store_session(res)
    @serialize_hash = @json_hash.to_json
    res.set_cookie('_rails_lite_app', @serialize_hash)
  end
end
```

#### Route methods

* The code below uses pattern to pull out route params and then instantiates controller and calls the appriopriate controller action

```ruby
def run(req, res)
    match_data = @pattern.match(req.path)
    hash = Hash[match_data.names.zip(match_data.captures)]
    controller = @controller_class.new(req, res, hash)
    controller.invoke_action(req.request_method.downcase.to_sym)
  end
```

* The code below defines method that when called adds the appriopriate route

```ruby
[:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end
```
