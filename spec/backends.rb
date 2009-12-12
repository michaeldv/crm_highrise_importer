require "active_resource"
begin
  require "fakeweb"
rescue LoadError
  puts "You need to install Fakeweb: gem install fakeweb"; exit
end

module Fake
  class Backend

    MODELS = [ :user, :person, :company, :task, :note, :task_category, :contact_data ]

    # Register URIs with FakeWeb and make it respond with the Factory built objects.
    #------------------------------------------------------------------------------
    MODELS.each do |model|
      define_method model do |n|
        options = n.times.inject([]) do |arr,|
          arr << { :body => Factory(model).to_xml(:root => model.to_s) }
        end
        FakeWeb.register_uri(:get, %r|http://highrise.crm/#{model.to_s.pluralize}/\d+.xml|, options)
      end
    
      define_method model.to_s.pluralize do |n|
        body = n.times.inject([]) { |arr,| arr << Factory(model) }
        FakeWeb.register_uri(:get, "http://highrise.crm/#{model.to_s.pluralize}.xml", :body => body.to_xml(:root => model.to_s))

        # Stub related tasks and notes.
        if model == :person || model == :company
          [ :task, :note ].each do |related|
            body = n.times.inject([]) { |arr,| arr << Factory(related) }
            FakeWeb.register_uri(:get, %r|http://highrise.crm/#{model.to_s.pluralize}/\d+/#{related.to_s.pluralize}.xml|, :body => body.to_xml(:root => related.to_s))
          end
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
