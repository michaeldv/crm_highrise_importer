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
    MODELS.each do |model|
      define_method model do |n|
        options = n.times.inject([]) do |arr,|
          arr << { :body => Factory(model).to_xml.gsub(PREFIX, "<\\1") }
        end
        FakeWeb.register_uri(:get, %r|http://highrise.crm/#{model.to_s.pluralize}/\d+.xml|, options)
      end
    
      define_method model.to_s.pluralize do |n|
        body = n.times.inject([]) do |arr,|
          arr << Factory(model)
        end.to_xml.gsub(PREFIX, "<\\1")
        FakeWeb.register_uri(:get, "http://highrise.crm/#{model.to_s.pluralize}.xml", :body => body)

        # Stub related tasks.
        if model == :person || model == :company
          body = n.times.inject([]) do |arr,|
            arr << Factory(:task)
          end.to_xml.gsub(PREFIX, "<\\1")
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
