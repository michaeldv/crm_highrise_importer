module FatFreeCRM
  module Highrise
    class Import

      class << self
        attr_accessor :users, :fat_free_crm_users
        attr_accessor :categories
        attr_accessor :admin

        PASSWORD = "p@ssword" # Default password for imported users.

        #------------------------------------------------------------------------------
        def users
          @@users ||= []
          @@fat_free_crm_users ||= []
          if @@users.empty?
            @@users = FatFreeCRM::Highrise::User.find(:all)
            @@users.each { |u| import_user(u) }
          end
          @@users
        end

        #------------------------------------------------------------------------------
        def fat_free_crm_users
          @@fat_free_crm_users ||= ::User.all
        end

        #------------------------------------------------------------------------------
        def categories
          @@categories ||= TaskCategory.find(:all)
        end

        #------------------------------------------------------------------------------
        def admin
          @@admin ||= ::User.first(:conditions => {:admin => true})
        end

        #------------------------------------------------------------------------------
        def people
          people = Person.find(:all)
          people = people.select { |person| not is_user?(person) } # Select people who are not users.
          contacts = people.inject([]) do |arr, p|
            arr << import_person(p)
          end
          [ people, contacts ]
        end

        #------------------------------------------------------------------------------
        def companies
          companies = Company.find(:all)
          accounts = companies.inject([]) do |arr, c|
            arr << import_company(c)
          end
          [ companies, accounts ]
        end

        # Import related tasks for Companies (Accounts) or People (Contacts).
        #------------------------------------------------------------------------------
        def related_tasks(exported, imported)
          before, after = [], []
          exported.zip(imported).each do |ex, im|
            x, y = import_related_task(ex, im)
            before << x
            after  << y
          end
          [ before.flatten, after.flatten ]
        end

        #------------------------------------------------------------------------------
        def standalone_tasks
          before = FatFreeCRM::Highrise::Task.find(:all)
          before = before.select { |t| t.subject_id.nil? } # Select non-related tasks only.
          after = before.inject([]) do |arr, t|
            arr << import_task(t)
          end
          [ before, after ]
        end

        # Import notes for Companies (Accounts) or People (Contacts).
        #------------------------------------------------------------------------------
        def notes(exported, imported)
          before, after = [], []
          exported.zip(imported).each do |ex, im|
            x, y = import_note(ex, im)
            before << x
            after  << y
          end
          [ before.flatten, after.flatten ]
        end

        private
        #------------------------------------------------------------------------------
        def import_user(user)
          fat_free_crm_user = ::User.find_by_username(user.name)
          unless fat_free_crm_user
            person = Person.find(:conditions => {:email_address => user.email_address})
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
            @@fat_free_crm_users << fat_free_crm_user
          end
          fat_free_crm_user
        end

        #------------------------------------------------------------------------------
        def import_person(person)
          contact = Contact.create!(
            :user_id     => author(person),
            :assigned_to => owner(person),
            :first_name  => (person.first_name || 'HIGHRISE')[0..63],
            :last_name   => (person.last_name || 'HIGHRISE')[0..63],
            :title       => (person.title || '')[0..63],
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
            :created_at  => person.created_at
          )
          if person.contact_data.addresses.present?
            highrise_address = person.contact_data.addresses.first
            contact.business_address = ::Address.new(:full_address => extract(person.contact_data, :address))
            contact.save!
          end
          
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
            :user_id          => author(company),
            :assigned_to      => owner(company),
            :name             => company.name[0..63],
            :access           => "Public",
            :website          => extract(company.contact_data, :website),
            :toll_free_phone  => extract(company.contact_data, :tall_free_phone),
            :phone            => extract(company.contact_data, :work_phone),
            :fax              => extract(company.contact_data, :fax_phone),
            :created_at       => company.created_at
          )
          if company.contact_data.addresses.present?
            highrise_address = company.contact_data.addresses.first
            account.billing_address = ::Address.new(:full_address => extract(company.contact_data, :address))
            account.shipping_address = ::Address.new(:full_address => extract(company.contact_data, :address))
            account.save!
          end
          # puts account.inspect
          account
        end

        # Import tasks related to a model with polymorphic subject_id/subject_type set.
        #------------------------------------------------------------------------------
        def import_task(task, related = nil)
          ::Task.create!(
            :user_id      => author(task),
            :assigned_to  => owner(task),
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

        # Import a task related to a model with polymorphic subject_id/subject_type set.
        #------------------------------------------------------------------------------
        def import_related_task(model, related)
          tasks = model.tasks
          imported_tasks = tasks.inject([]) do |arr, task|
            arr << import_task(task, related)
          end
          [ tasks, imported_tasks ]
        end

        # Import a note related to a model with polymorphic subject_id/subject_type set.
        #------------------------------------------------------------------------------
        def import_note(model, related)
          notes = model.notes
          imported_notes = notes.inject([]) do |arr, note|
            ::Comment.after_create.clear # Disable activity logging.
            arr << ::Comment.create!(
              :user_id          => author(note),
              :commentable_id   => related.id,
              :commentable_type => related.class.to_s,
              :private          => false,
              :title            => "",
              :comment          => note.body[0..254],
              :created_at       => note.created_at
            )
          end
          [ notes, imported_notes ]
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
          false # People are separate from users now
        end

        #------------------------------------------------------------------------------
        def author(model)
          admin.id
        end

        def owner(model)
          admin.id
        end
      end

    end
  end
end
