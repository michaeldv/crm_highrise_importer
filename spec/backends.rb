require "active_resource"
begin
  require "fakeweb"
rescue LoadError
  puts "You need to install Fakeweb: gem install fakeweb"; exit
end

module Fake
  class Backend

    def self.build(entities, number_of_records = 3)
      backend = self.new
      backend.send(entities, number_of_records)
    end

    # Register URIs with FakeWeb and make it respond with the Factory built objects.
    #------------------------------------------------------------------------------
    [ :person, :company ].each do |entity|                                                                    #
      define_method entity do |n|                                                                             # def person
        data = Factory(entity)                                                                                #   data = Factory(:person)
        body = data.to_xml.gsub(%r|<(/*)fat-free-crm/highrise/|, "<\\1") # Remove module names.               #   body = data.to_xml.gsub(%r|<(/*)fat-free-crm/highrise/|, "<\\1")
        FakeWeb.register_uri(:get, %r|http://highrise.crm/#{entity.to_s.pluralize}/\d+.xml|, :body => body)   #   FakeWeb.register_uri(:get, %r|http://highrise.crm/people/\d+.xml|, :body => body)
      end                                                                                                     # end
    
      define_method entity.to_s.pluralize do |n|                                                              # def people(n)
        data = n.times.inject([]) { |arr,| arr << Factory(entity) }                                           #   data = n.times.inject([]) { |arr,| arr << Factory(:person) }
        body = data.to_xml.gsub(%r|<(/*)fat-free-crm/highrise/|, "<\\1") # Remove module names.               #   body = data.to_xml.gsub(%r|<(/*)fat-free-crm/highrise/|, "<\\1")
        FakeWeb.register_uri(:get, "http://highrise.crm/#{entity.to_s.pluralize}.xml", :body => body)         #   FakeWeb.register_uri(:get, "http://highrise.crm/people.xml", :body => body)
      end                                                                                                     # end
    end                                                                                                       #

  end
end

def Backend(entities, number_of_records = 3)
  Fake::Backend.build(entities, number_of_records)
end
