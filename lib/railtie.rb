require 'copydb'
require 'rails'

class CopydbRailtie < Rails::Railtie
  rake_tasks do
    load File.join(File.dirname(__FILE__),'/tasks/copydb.rake')
  end
  
  def hi
    puts "hello world!"
  end
end
