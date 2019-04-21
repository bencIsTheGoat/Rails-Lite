require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, params_hash = {})
    @req = req
    @res = res
    @params = params_hash.merge(req.params)
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response ||= false
  end

  # Set the response status code and header
  def redirect_to(url)
    unless already_built_response?
      @res.set_header('Location', url)
      @res.status = 302
      @already_built_response = true
      self.session.store_session(@res)
    else
      raise
    end

  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
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

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    #debugger
    view_folder = self.class.to_s.underscore
    view = File.dirname(view_folder)
    text = File.read("views/#{view_folder}/#{template_name}.html.erb")
    erb = ERB.new(text).result(binding)
    render_content(erb, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(render, name)
  end
end

