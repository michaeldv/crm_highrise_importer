require "active_resource"
begin
  require "fakeweb"
rescue LoadError
  puts "You need to install Fakeweb: gem install fakeweb"; exit
end

module Fake
  class Backend

    MODELS = [ :user, :person, :company, :task, :task_category, :contact_data ]
    PREFIX = %r|<(/*)fat-free-crm/highrise/|

    # Register URIs with FakeWeb and make it respond with the Factory built objects.
    #------------------------------------------------------------------------------
    MODELS.each do |model|                                                                                 #
      define_method model do |n|                                                                           # def person
        data = Factory(model)                                                                              #   data = Factory(:person)
        body = data.to_xml.gsub(PREFIX, "<\\1") # Remove module names.                                     #   body = data.to_xml.gsub(%r|<(/*)fat-free-crm/highrise/|, "<\\1")
        FakeWeb.register_uri(:get, %r|http://highrise.crm/#{model.to_s.pluralize}/\d+.xml|, :body => body) #   FakeWeb.register_uri(:get, %r|http://highrise.crm/people/\d+.xml|, :body => body)
      end                                                                                                  # end
    
      define_method model.to_s.pluralize do |n|                                                            # def people(n)
        data = n.times.inject([]) { |arr,| arr << Factory(model) }                                         #   data = n.times.inject([]) { |arr,| arr << Factory(:person) }
        body = data.to_xml.gsub(PREFIX, "<\\1")                                                            #   body = data.to_xml.gsub(%r|<(/*)fat-free-crm/highrise/|, "<\\1")
        FakeWeb.register_uri(:get, "http://highrise.crm/#{model.to_s.pluralize}.xml", :body => body)       #   FakeWeb.register_uri(:get, "http://highrise.crm/people.xml", :body => body)

        # Stub related tasks.
        if model == :person || model == :company
          data = n.times.inject([]) { |arr,| arr << Factory(:task) }
          body = data.to_xml.gsub(PREFIX, "<\\1")
          FakeWeb.register_uri(:get, %r|http://highrise.crm/#{model.to_s.pluralize}/\d+/tasks.xml|, :body => body)
        end
      end

    end

    # Stub models by invoking methods that register fake model URLs.
    #------------------------------------------------------------------------------
    def stub(*models)
      number_of_records = 5
      backends = (models == [ :all ] ? MODELS : models)
      backends.each do |backend|
        send(backend, number_of_records)
        send(backend.to_s.pluralize.to_sym, number_of_records)
      end
    end

  end
end
