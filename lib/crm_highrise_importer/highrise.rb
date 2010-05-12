require "active_resource"

module FatFreeCRM
  module Highrise

    class Base < ActiveResource::Base
      self.site = ENV["SITE"]

      def save!
        true
      end
    end

    #------------------------------------------------------------------------------
    class CoreObject < Base
      def notes
        Note.find(:all, :from => "/#{self.class.collection_name}/#{id}/notes.xml")
      end

      def emails
        Email.find(:all, :from => "/#{self.class.collection_name}/#{id}/emails.xml")
      end

      def tasks
        Task.find(:all, :from => "/#{self.class.collection_name}/#{id}/tasks.xml")
      end

      def self.find_all_across_pages(options = {})
        records = []
        each(options) { |record| records << record }
        records
      end

      def self.each(options = {})
        options[:params] ||= {}
        options[:params][:n] = 0

        loop do
          if (records = self.find(:all, options)).any?
            records.each { |record| yield record }
            options[:params][:n] += records.size
          else
            break # no people included on that page, thus no more people total
          end
        end
      end

    end

    # ~~~~~~~~~~~ Person
    # integer     :id
    # integer     :author_id
    # integer     :owner_id
    # integer     :group_id
    # integer     :company_id
    # string      :background
    # string      :first_name
    # string      :last_name
    # string      :title
    # string      :visible_to
    # datetime    :updated_at
    # datetime    :created_at
    #------------------------------------------------------------------------------
    class Person < CoreObject

      def company
        Company.find(company_id) if company_id
      end
    end

    # ~~~~~~~~~~~ Company
    # integer     :id
    # integer     :author_id
    # integer     :group_id
    # integer     :owner_id
    # string      :name
    # string      :background
    # string      :visible_to
    # datetime    :updated_at
    # datetime    :created_at
    #------------------------------------------------------------------------------
    class Company < CoreObject
      def people
        Person.find(:all, :from => "/companies/#{id}/people.xml")
      end
    end
  
    # ~~~~~~~~~~~ Deal
    # integer     :id
    # integer     :account_id
    # integer     :author_id
    # integer     :category_id
    # integer     :group_id
    # integer     :owner_id
    # integer     :party_id
    # integer     :responsible_party_id
    # string      :name
    # string      :background
    # string      :status
    # string      :currency
    # integer     :duration
    # integer     :price
    # string      :price_type
    # string      :visible_to
    # date        :status_changed_on
    # datetime    :updated_at
    # datetime    :created_at
    #------------------------------------------------------------------------------
    class Deal < CoreObject
    end
  
    # ~~~~~~~~~~~ User
    # integer     :id
    # integer     :person_id
    # datetime    :updated_at
    # datetime    :created_at
    #------------------------------------------------------------------------------
    class User < Base
    end

    # ~~~~~~~~~~~ Task
    # integer     :id
    # integer     :author_id
    # integer     :owner_id
    # integer     :recording_id
    # integer     :category_id
    # integer     :subject_id
    # string      :subject_type
    # boolean     :public
    # string      :body
    # string      :frame
    # datetime    :done_at
    # datetime    :alert_at
    # datetime    :updated_at
    # datetime    :created_at
    #------------------------------------------------------------------------------
    class Task < Base
      def self.upcoming
        find(:all, :from => :upcoming)
      end

      def self.assigned
        find(:all, :from => :assigned)
      end

      def self.completed
        find(:all, :from => :completed)
      end
    end
  
    # ~~~~~~~~~~~ ContactData
    #------------------------------------------------------------------------------
    class ContactData < Base
    end
  
    # ~~~~~~~~~~~ Address
    # integer     :id
    # string      :street
    # string      :city
    # string      :state
    # string      :zip
    # string      :country
    # string      :location %w(Work Home Other)
    #------------------------------------------------------------------------------
    class Address < Base
    end
  
    # ~~~~~~~~~~~ EmailAddress
    # integer     :id
    # string      :address
    # string      :location %w(Work Home Other)
    #------------------------------------------------------------------------------
    class EmailAddress < Base
    end
  
    # ~~~~~~~~~~~ InstantMessenger
    # integer     :id
    # string      :address
    # string      :protocol %w(AIM MSN ICQ Jabber Yahoo Skype QQ Sametime Gadu-Gadu Google\ Talk Other)
    # string      :location %w(Work Personal Other)
    #------------------------------------------------------------------------------
    class InstantMessenger < Base
    end
  
    # ~~~~~~~~~~~ PhoneNumber
    # integer     :id
    # string      :number
    # string      :location %w(Work Mobile Fax Pager Home Other)
    #------------------------------------------------------------------------------
    class PhoneNumber < Base
    end
  
    # ~~~~~~~~~~~ TwitterAccount
    # integer     :id
    # string      :username
    # string      :location %w(Personal Business Other)
    #------------------------------------------------------------------------------
    class TwitterAccount < Base
    end
  
    # ~~~~~~~~~~~ WebAddress
    # integer     :id
    # string      :url
    # string      :location %w(Work Personal Other)
    #------------------------------------------------------------------------------
    class WebAddress < Base
    end
  
    # ~~~~~~~~~~~ Note
    # integer     :id
    # integer     :subject_id
    # integer     :author_id
    # integer     :group_id
    # integer     :kase_id
    # integer     :owner_id
    # string      :subject_type
    # string      :body
    # string      :visible_to
    # datetime    :updated_at
    # datetime    :created_at
    #------------------------------------------------------------------------------
    class Note < Base
      def comments
        Comment.find(:all, :from => "/notes/#{id}/comments.xml")
      end
    end
  
    # ~~~~~~~~~~~ Attachment
    # integer     :id
    # string      :url
    # string      :name
    # integer     :size
    #------------------------------------------------------------------------------
    class Attachment < Base
    end
  
    # ~~~~~~~~~~~ Email
    # integer     :id
    # integer     :author_id
    # integer     :group_id
    # integer     :kase_id
    # integer     :owner_id
    # integer     :subject_id
    # string      :subject_type
    # string      :title
    # string      :body
    # string      :visible_to
    # datetime    :updated_at
    # datetime    :created_at
    #------------------------------------------------------------------------------
    class Email < Base
      def comments
        Comment.find(:all, :from => "/emails/#{id}/emails.xml")
      end
    end
  
    # ~~~~~~~~~~~ Comment
    # integer     :id
    # integer     :author_id
    # integer     :parent_id
    # string      :body
    # datetime    :created_at
    #------------------------------------------------------------------------------
    class Comment < Base
    end

    # ~~~~~~~~~~~ TaskCategory
    # integer     :id
    # string      :name
    # integer     :account_id
    # integer     :elements_count
    # datetime    :updated_at
    # datetime    :created_at
    #------------------------------------------------------------------------------
    class TaskCategory < Base
    end

  end
end
