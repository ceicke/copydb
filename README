# CopyDb

CopyDb is a tool for exporting your database into a YAML format. It does essentially the same as YamlDb so far.

## Installation

Simply add it to your Gemfile and run the bundle ocmmand

  gem 'copydb'
  
  bundle install
  

## Usage

Once you have included CopyDb into your Rails project, you will have two new rake tasks, rake db:copydb:dump and rake db:copydb:load

  rake db:copydb:dump -> Dumps the content of the database to tmp/copydb_dumped_data.yml
  rake db:copydb:load -> Loads the content of the database from tmp/copydb_dumped_data.yml
  
Please be aware that you have to have an empty database with in at least the same schema version as the database is in that you got the data from.

## Credits

Created by Christoph Eicke, thanks to Orion Henry and Adam Wiggins for YamlDb.