module FatFreeCRM
  module Highrise
    class Import

      class << self
        attr_accessor :users
        attr_accessor :categories

        PASSWORD = "p@ssword"

        #------------------------------------------------------------------------------
        def users
          @@users ||= {}
          if @@users.empty?
            @@users = FatFreeCRM::Highrise::User.find(:all)
            @@users.each { |u| import_user(u) }
          end
          @@users
        end

        #------------------------------------------------------------------------------
        def people
          people = Person.find(:all)
          people.select { |person| not is_user?(person) }.each do |p|
            contact = import_person(p)
            import_related_tasks(p, contact)
          end
        end

        #------------------------------------------------------------------------------
        def companies
          companies = Company.find(:all)
          companies.each do |c|
            account = import_company(c)
            import_related_tasks(c, account)
          end
        end

        #------------------------------------------------------------------------------
        def categories
          @@categories ||= TaskCategory.find(:all)
        end

        #------------------------------------------------------------------------------
        def tasks
          tasks = FatFreeCRM::Highrise::Task.find(:all)
          tasks.each { |t| import_task(t) unless t.subject_id }
        end

        private
        #------------------------------------------------------------------------------
        def import_user(user)
          fat_free_crm_user = ::User.find_by_username(user.name)
          unless fat_free_crm_user
            person = Person.find(user.person_id)
            email = extract(person.contact_data, :work_email) || extract(person.contact_data, :home_email) || "#{user.name}@example.com"
            fat_free_crm_user = ::User.create!(
              :username   => user.name,
              :password   => PASSWORD,
              :password_confirmation => PASSWORD,
              :email      => email,
              :first_name => person.first_name[0..63],
              :last_name  => person.last_name[0..63],
              :title      => person.title[0..63],
              :phone      => extract(person.contact_data, :work_phone),
              :mobile     => extract(person.contact_data, :mobile_phone),
              :created_at => user.created_at
              )
          end
        end

        #------------------------------------------------------------------------------
        def import_person(person)
          contact = Contact.create!(
            :user_id     => 1,
            :assigned_to => 1,
            :first_name  => person.first_name[0..63],
            :last_name   => person.last_name[0..63],
            :title       => person.title[0..63],
            :access      => "Public",
            :email       => extract(person.contact_data, :work_email),
            :alt_email   => extract(person.contact_data, :home_email),
            :phone       => extract(person.contact_data, :work_phone),
            :mobile      => extract(person.contact_data, :mobile_phone),
            :fax         => extract(person.contact_data, :fax_phone),
            :blog        => extract(person.contact_data, :blog),
            :linkedin    => extract(person.contact_data, :linkedin),
            :facebook    => extract(person.contact_data, :facebook),
            :twitter     => extract(person.contact_data, :twitter),
            :address     => extract(person.contact_data, :address),
            :created_at  => person.created_at
          )
          if person.company
            account = import_company(person.company)
            AccountContact.create!(:account => account, :contact => contact)
          end
          # puts contact.inspect
          # puts contact.account.inspect
          contact
        end

        #------------------------------------------------------------------------------
        def import_company(company)
          account = Account.find_by_name(company.name[0..63]) ||
          Account.create!(
            :user_id          => 1,
            :assigned_to      => 1,
            :name             => company.name[0..63],
            :access           => "Public",
            :website          => extract(company.contact_data, :website),
            :toll_free_phone  => extract(company.contact_data, :tall_free_phone),
            :phone            => extract(company.contact_data, :work_phone),
            :fax              => extract(company.contact_data, :fax_phone),
            :billing_address  => extract(company.contact_data, :address),
            :shipping_address => extract(company.contact_data, :address),
            :created_at       => company.created_at
          )
          # puts account.inspect
          account
        end

        # Import tasks related to a model with polymorphic subject_id/subject_type set.
        #------------------------------------------------------------------------------
        def import_task(task, related = nil)
          ::Task.create!(
            :user_id      => 1,
            :assigned_to  => 1,
            :completed_by => nil,
            :name         => task.body[0..254],
            :asset_id     => related ? related.id : nil,
            :asset_type   => related ? related.class.to_s : nil,
            :priority     => nil,
            :category     => category(task),
            :bucket       => due_date(task),
            :due_at       => nil,
            :completed_at => task.done_at,
            :deleted_at   => nil,
            :created_at   => task.created_at
          )
        end

        # Import tasks related to a model with polymorphic subject_id/subject_type set.
        #------------------------------------------------------------------------------
        def import_related_tasks(model, related)
          model.tasks.each do |t|
            import_task(t, related)
          end
        end

        private
        #------------------------------------------------------------------------------
        def extract(contact_data, field)
          location = field.to_s.split("_").first.capitalize
          case field
          when :home_email, :work_email
            email = contact_data.email_addresses.detect { |addr| addr.location == location }
            email.address if email
          when :work_phone, :mobile_phone, :fax_phone
            phone = contact_data.phone_numbers.detect { |number| number.location == location }
            phone.number if phone
          when :tall_free_phone
            phone = contact_data.phone_numbers.detect { |number| number.number =~ /^\s*.{0,2}(800|888)[^\d]+/ }
            phone.number if phone
          when :website
            website = contact_data.web_addresses.detect { |site| site.location =~ /work|other/i }
            website.url if website
          when :blog
            website = contact_data.web_addresses.detect { |site| site.location =~ /personal|other/i }
            website.url if website
          when :linkedin
            website = contact_data.web_addresses.detect { |site| site.url =~ /linkedin/i }
            website.url if website
          when :facebook
            website = contact_data.web_addresses.detect { |site| site.url =~ /facebook/i }
            website.url if website
          when :twitter
            unless contact_data.twitter_accounts.blank?
              "http://twitter.com/#{contact_data.twitter_accounts.first.username}"
            end
          when :address
            unless contact_data.addresses.blank?
              addr = contact_data.addresses.first
              "#{addr.street}\n#{addr.city}, #{addr.state} #{addr.zip}\n#{addr.country}".strip
            end
          end
        end

        #------------------------------------------------------------------------------
        def due_date(task)
          return nil unless task.frame
          "due_#{task.frame}" if %w(today tomorrow this_week next_week later).include?(task.frame)
        end

        #------------------------------------------------------------------------------
        def category(task)
          return nil if categories.nil? || task.category_id.nil?
          category = categories.detect { |c| c.id == task.category_id }
          category.name if category
        end

        #------------------------------------------------------------------------------
        def is_user?(person)
          users.detect { |u| u.person_id == person.id }
        end

      end

    end
  end
end