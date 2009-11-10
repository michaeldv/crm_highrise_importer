require "active_resource"
begin
  require "fakeweb"
rescue LoadError
  puts "You need to install Fakeweb: gem install fakeweb"; exit
end

module Fake
  class Backend

    def self.build(entity, number_of_records = 3)
      backend = self.new
      backend.class_eval %Q~
        def #{entity}(n = #{number_of_records})                                                           # def people(n)
          data = n.times.inject([]) { |arr,| arr << Factory("#{entity}".singularize) }                    #   data = n.times.inject([]) { |arr,| arr << Factory(:person) }
          body = data.to_xml.gsub(%r{<(/*)highrise/}, '<\\1') # to_xml prepends module name, remove it.   #   body = data.to_xml.gsub(%r{<(/*)highrise/}, "<\\1")
          FakeWeb.register_uri(:get, "http://highrise.crm/#{entity}.xml", :body => body)                  #   FakeWeb.register_uri(:get, "http://highrise.crm/people.xml", :body => body)
        end~                                                                                              # end
      backend.send(entity, number_of_records)
    end

    # Register URIs with FakeWeb and make it respond with the Factory built objects.
    #------------------------------------------------------------------------------
    # [ :person, :company ].each do |entity|                                                              #
    #   define_method entity.to_s.pluralize do |n|                                                        # def people(n)
    #     data = n.times.inject([]) { |arr,| arr << Factory(entity) }                                     #   data = n.times.inject([]) { |arr,| arr << Factory(:person) }
    #     body = data.to_xml.gsub(%r{<(/*)highrise/}, "<\\1") # to_xml prepends module name, remove it.   #   body = data.to_xml.gsub(%r{<(/*)highrise/}, "<\\1")
    #     FakeWeb.register_uri(:get, "http://highrise.crm/#{entity.to_s.pluralize}.xml", :body => body)   #   FakeWeb.register_uri(:get, "http://highrise.crm/people.xml", :body => body)
    #   end                                                                                               # end
    # end                                                                                                 #

  end
end

def Backend(entity, number_of_records = 3)
  Fake::Backend.build(entity, number_of_records)
end
