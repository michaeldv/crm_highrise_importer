require File.dirname(__FILE__) + "/../lib/crm_highrise_importer/highrise"
require File.dirname(__FILE__) + "/../lib/crm_highrise_importer/import"

namespace :crm do
  namespace :highrise do

    desc "Import Highrise data"
    task :import => :environment do
      FatFreeCRM::Highrise::Base.site = "" # Ask user.
      puts "Importing Highrise data..."
      FatFreeCRM::Highrise::Import.people([])
    end

  end
end