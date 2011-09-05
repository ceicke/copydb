# encoding: utf-8
Gem::Specification.new do |s|
  s.name  = 'copydb'
  s.version = '0.1.0'
  s.date = '2011-09-02'
  s.summary = 'Copydb helps you synchronize your databases and can be configured to anonymize certain parts of a table'
  s.description = 'Copydb is a gem that helps you to copy databases e.g. from a production database to your development database. During the process it is possible to define columns in tables in which the data should be exchanged for fake data. This can be interesting in a scenario where you want to run your development machine with production data, but privacy laws (such as in Germany) prohibit you to use real data.'
  s.authors = ["Christoph Eicke"]
  s.email = 'eicke@yfu.de'
  s.files = ["lib/copydb.rb","lib/tasks/copydb.rake","lib/config/sampleconfig.yml"]
  s.homepage = 'https://github.com/ceicke/copydb'
  s.add_dependency("faker","~> 0.9.5")
end
  
  
