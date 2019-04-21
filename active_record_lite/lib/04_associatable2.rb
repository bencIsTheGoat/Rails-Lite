require_relative '03_associatable'
require 'active_support/inflector'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)

    
    define_method(name.to_s) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      
      through_name = through_options.table_name
      source_name = source_options.table_name
      source_id = source_options.foreign_key.to_s
   
      name_id = self.send(through_options.foreign_key)
      output =  DBConnection.execute(<<-SQL, name_id)
        SELECT 
          #{source_name}.*
        FROM
          #{through_name}
        JOIN
          #{source_name} ON #{through_name}.#{source_id} = #{source_name}.id
        WHERE
          #{through_name}.id = ?
      SQL
      
      source_options.model_class.parse_all(output).first

    end    
  end
end
