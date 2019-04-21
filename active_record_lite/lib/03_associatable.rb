require_relative '02_searchable'
require 'active_support/inflector'
require 'byebug'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    name = name.to_s.singularize
    defaults = {
    primary_key:  :id,
    foreign_key:  (name.underscore + "_id").to_sym,
    class_name:  name.camelcase
    }
    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    name = name.to_s.singularize
    self_class_name = self_class_name.to_s.singularize
    defaults = {
    primary_key:  :id,
    foreign_key:  (self_class_name.underscore + "_id").to_sym,
    class_name:  name.camelcase
    }
    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})

    self.assoc_options[name] = BelongsToOptions.new(name, options)

    define_method(name) do
      options = self.class.assoc_options[name]
      options.model_class.where({options.primary_key => self.send(options.foreign_key)}).first
    end
   
  end

  def has_many(name, options = {})

    self.assoc_options[name] = HasManyOptions.new(name, self.name, options)

    define_method(name) do
      options = self.class.assoc_options[name]
      options.model_class.where({options.foreign_key => self.send(options.primary_key)})
    end
    
  end

  def assoc_options
    @assoc_options ||= {}
    @assoc_options
  end
end

class SQLObject
  extend Associatable

end
