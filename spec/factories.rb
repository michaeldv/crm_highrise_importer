require "faker"
include FatFreeCRM::Highrise

ADDRESSES = [ :addresses, :email_addresses, :instant_messengers, :twitter_accounts, :web_addresses ]

Factory.sequence :username do |x|
  Faker::Internet.user_name + x.to_s
end

Factory.sequence :website do |x|
  "http://www." + Faker::Internet.domain_name
end

Factory.sequence :location do |x|
  %w(Work Home Other).rand
end

Factory.sequence :protocol do |x|
  %w(AIM MSN ICQ Jabber Yahoo Skype QQ Sametime Gadu-Gadu Google\ Talk Other).rand
end

Factory.sequence :time do |x|
  Time.now - x.hours
end

Factory.sequence :date do |x|
  Date.today - x.days
end

ADDRESSES.each do |addr|                                                                  #
  Factory.sequence addr do |x| # Use homegrown version of singularize.                    # Factory.sequence :addresses do |x|
    rand(4).times.inject([]) { |arr,| arr << Factory(addr.to_s.sub(/e*s$/, "").to_sym) }  #   rand(4).times.inject([]) { |arr,| arr << Factory(:address) }
  end                                                                                     # end
end                                                                                       #

#------------------------------------------------------------------------------
Factory.define :contact_data do |a|
  ADDRESSES.each do |addr|
    a.send(addr)        { Factory.next(addr) }
  end
end

#------------------------------------------------------------------------------
Factory.define :person do |a|
  a.author_id           rand(999)
  a.owner_id            rand(999)
  a.group_id            rand(999)
  a.company_id          rand(999)
  a.background          { Faker::Lorem::paragraph }
  a.first_name          { Faker::Name.first_name }
  a.last_name           { Faker::Name.last_name }
  a.title               { Faker::Lorem.sentence }
  a.visible_to          "Everyone"
  a.updated_at          { Factory.next(:time) }
  a.created_at          { Factory.next(:time) }
  a.contact_data        { |a| a.association(:contact_data) }
end

#------------------------------------------------------------------------------
Factory.define :company do |a|
  a.author_id           rand(999)
  a.owner_id            rand(999)
  a.group_id            rand(999)
  a.name                { Faker::Company.name }
  a.background          { Faker::Lorem::paragraph }
  a.updated_at          { Factory.next(:time) }
  a.created_at          { Factory.next(:time) }
  a.contact_data        { |a| a.association(:contact_data) }
end

#------------------------------------------------------------------------------
Factory.define :deal do |a|
  a.account_id          rand(999)
  a.author_id           rand(999)
  a.category_id         rand(999)
  a.owner_id            rand(999)
  a.group_id            rand(999)
  a.party_id            rand(999)
  a.reponsible_party_id rand(999)
  a.name                { Faker::Lorem.sentence }
  a.background          { Faker::Lorem::paragraph }
  a.status              { Faker::Lorem.sentence }
  a.currency            { Faker::Lorem.sentence }
  a.duration            rand(999)
  a.price               rand(999)
  a.price_type          { Faker::Lorem.sentence }
  a.visible_to          "Everyone"
  a.status_changed_on   { Factory.next(:date) }
  a.updated_at          { Factory.next(:time) }
  a.created_at          { Factory.next(:time) }
end

#------------------------------------------------------------------------------
Factory.define :task do |a|
  a.author_id           rand(999)
  a.recording_id        rand(999)
  a.category_id         rand(999)
  a.subject_id          nil
  a.subject_type        nil
  a.public              true
  a.body                { Faker::Lorem::paragraph }
  a.frame               { Faker::Lorem.sentence }
  a.due_at              { Factory.next(:time) }
  a.alert_at            { Factory.next(:time) }
  a.updated_at          { Factory.next(:time) }
  a.created_at          { Factory.next(:time) }
end

#------------------------------------------------------------------------------
Factory.define :note do |a|
  a.author_id           rand(999)
  a.group_id            rand(999)
  a.kase_id             rand(999)
  a.owner_id            rand(999)
  a.subject_id          nil
  a.subject_type        nil
  a.body                { Faker::Lorem::paragraph }
  a.visible_to          "Everyone"
  a.updated_at          { Factory.next(:time) }
  a.created_at          { Factory.next(:time) }
end

#------------------------------------------------------------------------------
Factory.define :attachment do |a|
  a.url                 { Factory.next(:website) }
  a.name                { Faker::Lorem.sentence }
  a.size                rand(999)
end

#------------------------------------------------------------------------------
Factory.define :email do |a|
  a.author_id           rand(999)
  a.group_id            rand(999)
  a.kase_id             rand(999)
  a.owner_id            rand(999)
  a.subject_id          nil
  a.subject_type        nil
  a.title               { Faker::Lorem.sentence }
  a.body                { Faker::Lorem::paragraph }
  a.visible_to          "Everyone"
  a.updated_at          { Factory.next(:time) }
  a.created_at          { Factory.next(:time) }
end

#------------------------------------------------------------------------------
Factory.define :comment do |a|
  a.author_id           rand(999)
  a.parent_id           rand(999)
  a.body                { Faker::Lorem::paragraph }
  a.created_at          { Factory.next(:time) }
end

#------------------------------------------------------------------------------
Factory.define :address do |a|
  a.street              { Faker::Address.street_address }
  a.city                { Faker::Address.city }
  a.state               { Faker::Address.us_state_abbr }
  a.zip                 { Faker::Address.zip_code }
  a.country             "USA"
  a.location            { Factory.next(:location) }
end

#------------------------------------------------------------------------------
Factory.define :email_address do |a|
  a.address             { Faker::Internet.email }
  a.location            { Factory.next(:location) }
end

#------------------------------------------------------------------------------
Factory.define :instant_messenger do |a|
  a.address             { Faker::Internet.email }
  a.protocol            { Factory.next(:protocol) }
  a.location            { Factory.next(:location) }
end

#------------------------------------------------------------------------------
Factory.define :twitter_account do |a|
  a.username            { Factory.next(:username) }
  a.location            { Factory.next(:location) }
end

#------------------------------------------------------------------------------
Factory.define :web_address do |a|
  a.url                 { Factory.next(:website) }
  a.location            { Factory.next(:location) }
end
