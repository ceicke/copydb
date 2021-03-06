require 'rubygems'
require 'yaml'
require 'active_record'
require 'active_support/core_ext/kernel/reporting'
require 'rails/railtie'
require 'fileutils'
require 'faker'

module CopyDb
  
  class DumpDb
    def dump
      
      anonymizer = CopyDb::Config.read_anonymize_config
      
      output = File.new(File.expand_path('db/copydb_dumped_data.yml'), "w+")
      yml = [self.schema_version]
      self.tables.each do |table|
        if anonymizer.has_key?(table)
          yml << self.table_dump_anonymous(table,anonymizer[table])
        else
          yml << self.table_dump(table)
        end
      end
      output.write(yml.to_yaml)
      output.close
    end
    
    def tables
      ActiveRecord::Base.connection.tables.reject { |table| ['schema_info', 'schema_migrations'].include?(table) }
    end
    
    def table_column_names(table)
      ActiveRecord::Base.connection.columns(table).map { |c| c.name }
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
    
    def table_dump_anonymous(table,anonymize_column_configurations)
      
      column_names = Array.new
      anonymizing_types = Array.new
      
      anonymize_column_configurations.each do |anonymize_column_configuration|
        column_names << anonymize_column_configuration.keys[0]
        anonymizing_types << anonymize_column_configuration.values[0]
      end
      
      rs = ActiveRecord::Base.connection.execute("SELECT * FROM #{table}")
      yml = Array.new
      yml << table
      rs.each do |result|
        resultHash = Hash.new
        result.each do |result_column,result_value|          
          
          if column_names.include?(result_column)
            anonymize_type = anonymizing_types[(column_names.index(result_column))]
            resultHash[result_column] = CopyDb::Anonymizer.anonymize(anonymize_type)
          else
            resultHash[result_column] = result_value
          end
                    
        end
        yml << resultHash
      end
      yml
    end
    
    def schema_version
       ActiveRecord::Migrator.current_version
    end
  end
  
  class LoadDb
    def load
      if FileTest.exists?(File.expand_path('db/copydb_dumped_data.yml'))

        yml = YAML.load_file(File.expand_path('db/copydb_dumped_data.yml'))

        yml.each_with_index do |entry,i|
          if i == 0
            unless entry.to_s == self.schema_version.to_s
              puts "ERROR: schema version mismatch"
            end
            next
          end
          unless entry[1].nil?
            ActiveRecord::Base.connection.begin_db_transaction
            columns = entry[1].each_key.to_a
            quoted_column_names = columns.map { |column| ActiveRecord::Base.connection.quote_column_name(column) }.join(',')
            
            for i in 1..(entry.length-1)
              entries = entry[i].each_value.to_a
              quoted_column_values = entries.map { |record| ActiveRecord::Base.connection.quote(record) }.join(',')

	      ActiveRecord::Base.connection.execute("ALTER TABLE #{entry[0]} DISABLE TRIGGER ALL;")
              
              sql_string = "INSERT INTO #{entry[0]} (#{quoted_column_names}) VALUES (#{quoted_column_values});"
              ActiveRecord::Base.connection.execute(sql_string)

	      ActiveRecord::Base.connection.execute("ALTER TABLE #{entry[0]} ENABLE TRIGGER ALL;")
            end            
	    ActiveRecord::Base.connection.commit_db_transaction
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
  
  class Config    
    def self.read_anonymize_config
      if FileTest.exists?(File.expand_path('config/copydb_anonymize.yml'))
        YAML.load_file(File.expand_path('config/copydb_anonymize.yml'))
      else
        Hash.new
      end
    end
  end
  
  class Anonymizer
    
    Faker::Config.locale = "en"
    
    def self.anonymize(type)
      if type == "name"
        Faker::Name.name
      elsif type == "first_name"
        Faker::Name.first_name
      elsif type == "last_name"
        Faker::Name.last_name
      elsif type == "street_address"
        Faker::Address.street_address
      elsif type == "city"
        Faker::Address.city
      elsif type == "zip"
        Faker::Address.zip_code
      elsif type == "phone"
        Faker::PhoneNumber.phone_number
      elsif type == "email"
        Faker::Internet.free_email
      elsif type == "company"
        Faker::Company.name
      elsif type == "date"
        "2011-11-11"
      elsif type == "lorem"
	Faker::Lorem.sentence(20)
      else
        Faker::Lorem.sentence
      end
    end
  end
  
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.expand_path('../tasks/copydb.rake',__FILE__)
    end
  end
end
