require 'rubygems'
require 'yaml'
require 'active_record'
require 'active_support/core_ext/kernel/reporting'
require 'rails/railtie'

module CopyDb
  
  class DumpDb
    def dump
      o = File.new(File.expand_path('tmp/copydb_dumped_data.yml'), "w+")
      yml = [self.schema_version]
      self.tables.each do |table|
        puts "Dumping table: #{table}"
        yml << self.table_dump(table)
      end
      o.write(yml.to_yaml)
      o.close
    end
    
    def tables
      ActiveRecord::Base.connection.tables.reject { |table| ['schema_info', 'schema_migrations'].include?(table) }
    end
    
    def table_dump(table)
      rs = ActiveRecord::Base.connection.execute("SELECT * FROM #{table}")
      yml = Array.new
      yml << table
      rs.each do |r|
        yml << r
      end
      yml
    end
    
    def schema_version
       ActiveRecord::Migrator.current_version
    end
  end
  
  class LoadDb
    def load
      if FileTest.exists?(File.expand_path('tmp/copydb_dumped_data.yml'))

        yml = YAML.load_file(File.expand_path('tmp/copydb_dumped_data.yml'))
  

        yml.each_with_index do |entry,i|
          if i == 0
            next # check for schema version here
          end
          unless entry[1].nil?
            quoted_column_names = entry[1].each_key.to_a.map { |column| ActiveRecord::Base.connection.quote_column_name(column) }.join(',')
            
            for i in 1..(entry.length-1)
              quoted_column_values = entry[i].each_value.to_a.map { |record| ActiveRecord::Base.connection.quote(record) }.join(',')
              
              sql_string = "INSERT INTO #{entry[0]} (#{quoted_column_names}) VALUES (#{quoted_column_values});"
              ActiveRecord::Base.connection.execute(sql_string)
            end            
          end
        end
      else
        puts "ERROR: dump file not found"
        exit 1
      end
    end
    
    def schema_version
       ActiveRecord::Migrator.current_version
    end
  end
  
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.expand_path('../tasks/copydb.rake',__FILE__)
    end
  end
end
