require File.dirname(__FILE__) + "/../lib/crm_highrise_importer/highrise"
require File.dirname(__FILE__) + "/../lib/crm_highrise_importer/import"

namespace :crm do
  namespace :highrise do

    desc "Import Highrise data"
    task :import => :environment do
      FatFreeCRM::Highrise::Base.site = ENV['SITE'] # Ask user.
      puts "Importing Highrise data..."

      people, contacts = FatFreeCRM::Highrise::Import.people
      FatFreeCRM::Highrise::Import.notes(people, contacts)
      companies, accounts = FatFreeCRM::Highrise::Import.companies
      FatFreeCRM::Highrise::Import.notes(companies, contacts)
      # TODO: missing emails
    end

  end
end
