module FatFreeCRM
  module Highrise
    class Import

      #------------------------------------------------------------------------------
      def self.people(people)
        people.each { |p| import_person(p) }
      end

      #------------------------------------------------------------------------------
      def self.companies(companies)
        companies.each { |c| import_company(c) }
      end


      private
      #------------------------------------------------------------------------------
      def self.import_person(person)
        contact = Contact.create(
          :first_name => person.first_name[0..64],
          :last_name  => person.last_name[0..64],
          :access     => "Public",
          :created_at => person.created_at
        )
        if person.company
          account = self.import_company(person.company)
          AccountContact.create(:account => account, :contact => contact)
        end
        puts contact.inspect
        puts contact.account.inspect
        contact
      end

      #------------------------------------------------------------------------------
      def self.import_company(company)
        Account.find_or_create_by_name(company.name[0..64],
          :access     => "Public",
          :created_at => company.created_at
        )
      end

    end
  end
end