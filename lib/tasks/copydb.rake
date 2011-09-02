namespace :db do
  namespace :copydb do
  	desc "Dump database content"
	  task :dump => :environment do
		  dumper = CopyDb::DumpDb.new
      dumper.dump
	  end
  
    desc "Load database content"
    task :load => :environment do
      loader = CopyDb::LoadDb.new
      loader.load
    end
  end
end
