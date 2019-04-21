require_relative 'db_connection'
require_relative '01_sql_object'
require 'byebug'

module Searchable
  def where(params)
    set = params.values
    keys = params.keys.map { |key| "#{key} = ?" }.join(" AND ")
    found = DBConnection.execute(<<-SQL, *set)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{keys}
    SQL
   parse_all(found)
  end
end

class SQLObject
  extend Searchable
end
