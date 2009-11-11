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
          :title      => person.title[0..64],
          :access     => "Public",
          :email      => extract(person.contact_data, :work_email),
          :alt_email  => extract(person.contact_data, :home_email),
          :phone      => extract(person.contact_data, :work_phone),
          :mobile     => extract(person.contact_data, :mobile_phone),
          :fax        => extract(person.contact_data, :fax_phone),
          :blog       => nil,
          :linkedin   => nil,
          :facebook   => nil,
          :twitter    => nil,
          :address    => nil,
          :created_at => person.created_at
        )
        if person.company
          account = self.import_company(person.company)
          AccountContact.create(:account => account, :contact => contact)
        end
        puts contact.inspect
        # puts contact.account.inspect
        contact
      end

      #------------------------------------------------------------------------------
      def self.import_company(company)
        Account.find_or_create_by_name(company.name[0..64],
          :access     => "Public",
          :created_at => company.created_at
        )
      end

      private
      #------------------------------------------------------------------------------
      def self.extract(contact_data, field)
        location = field.to_s.split("_").first.capitalize
        case field
        when :home_email, :work_email
          email = contact_data.email_addresses.detect { |addr| addr.location == location }
          email.address if email
        when :work_phone, :mobile_phone, :fax_phone
          phone = contact_data.phone_numbers.detect { |number| number.location == location }
          phone.number if phone
        end
      end
    end
  end
end