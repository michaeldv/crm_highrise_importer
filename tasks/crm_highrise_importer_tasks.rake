require File.dirname(__FILE__) + "/../lib/crm_highrise_importer/highrise"
require File.dirname(__FILE__) + "/../lib/crm_highrise_importer/import"

namespace :crm do
  namespace :highrise do

    desc "Import Highrise data"
    task :import => :environment do
      FatFreeCRM::Highrise::Base.site = ENV['SITE'] # Ask user.

      puts "Importing people..."
      people, contacts = FatFreeCRM::Highrise::Import.people
      puts "  Importing related notes..."
      FatFreeCRM::Highrise::Import.notes(people, contacts)
      puts "  Importing related tasks..."
      FatFreeCRM::Highrise::Import.related_tasks(people, contacts)

      puts "Importing companies..."
      companies, accounts = FatFreeCRM::Highrise::Import.companies
      puts "  Importing related notes..."
      FatFreeCRM::Highrise::Import.notes(companies, contacts)
      puts "  Importing related tasks..."
      FatFreeCRM::Highrise::Import.related_tasks(companies, accounts)

      puts "Importing tasks..."
      FatFreeCRM::Highrise::Import.standalone_tasks
    end

  end
end
