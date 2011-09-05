# CopyDb

CopyDb is a tool for exporting your database into a YAML format. 

CopyDb can be configured to anonymize certain parts of the database so that you can work with production data without violating your local privacy laws.

## Installation

Simply add it to your Gemfile and run the bundle ocmmand

    gem 'copydb'
  
    bundle install
  

## Usage

Once you have included CopyDb into your Rails project, you will have two new rake tasks, `rake db:copydb:dump` and `rake db:copydb:load`

    rake db:copydb:dump -> Dumps the content of the database to tmp/copydb_dumped_data.yml
    rake db:copydb:load -> Loads the content of the database from tmp/copydb_dumped_data.yml
  
Please be aware that you have to have an empty database with in at least the same schema version as the database is in that you got the data from.


## Anonymizing

While exporting the database, CopyDb can anonymize certain columns of your database. Upon exporting, CopyDb looks for `{RAILS_ROOT}/config/copydb_anonymize.yml`. The file is standard YML format, here is an example:

    ---
    people:
    - firstname: first_name
    - middlename: name
    - lastname: last_name
    - nickname: name
    - address: street_address
    - city: city
    - zip: zip
    - phone: phone
    - email: email
    
After this example, here is an explanation:

    ---
    {tablename}:
    - {column_name}: {column_type}
    
Depending on your `column_type`, different data is generated. You can choose from the following types:

* name: a generic name (e.g. Miguel Larson)
* first_name: a random first name (e.g. Filiberto)
* last_name: a random last name (e.g. Jacobs)
* street_address: a complete street address (e.g. 53585 Harris Gardens)
* city: a city name (e.g. Princesston)
* zip: a zip code (e.g. 42358)
* phone: a phone number (e.g. (084)491-6537 x964)
* email: an e-mail address of a free-mailer (e.g. dave.koss@gmail.com)
* date: the date 2011-11-11

## Credits

Created by Christoph Eicke, thanks to Orion Henry and Adam Wiggins for YamlDb.