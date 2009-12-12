require "faker"
include FatFreeCRM::Highrise

ADDRESSES = [ :addresses, :email_addresses, :phone_numbers, :instant_messengers, :twitter_accounts, :web_addresses ]

Factory.sequence :id do |x|
  rand(9999) + x
end

Factory.sequence :uid do |x|
  [1, 2, 3, 4, 5][x % 5]
end

Factory.sequence :username do |x|
  Faker::Internet.user_name + x.to_s
end

Factory.sequence :website do |x|
  "http://www." + Faker::Internet.domain_name
end

Factory.sequence :location do |x|
  %w(Work Home Other).rand
end

Factory.sequence :phone_location do |x|
  %w(Work Mobile Fax Other).rand
end

Factory.sequence :website_location do |x|
  %w(Work Personal Other).rand
end

Factory.sequence :protocol do |x|
  %w(AIM MSN ICQ Jabber Yahoo Skype QQ Sametime Gadu-Gadu Google\ Talk Other).rand
end

Factory.sequence :time do |x|
  Time.now.utc - x.hours
end

Factory.sequence :date do |x|
  Date.today - x.days
end

ADDRESSES.each do |addr|                                                                  #
  Factory.sequence addr do |x| # Use homegrown version of singularize.                    # Factory.sequence :addresses do |x|
    rand(5).times.inject([]) { |arr,| arr << Factory(addr.to_s.sub(/e*s$/, "").to_sym) }  #   rand(5).times.inject([]) { |arr,| arr << Factory(:address) }
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
  a.add_attribute(:id)  { Factory.next(:id) }
  a.author_id           { Factory.next(:uid) }
  a.owner_id            { Factory.next(:uid) }
  a.group_id            { Factory.next(:id) }
  a.company_id          { Factory.next(:id) }
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
  a.add_attribute(:id)  { Factory.next(:id) }
  a.author_id           { Factory.next(:uid) }
  a.owner_id            { Factory.next(:uid) }
  a.group_id            { Factory.next(:id) }
  a.name                { Faker::Company.name }
  a.background          { Faker::Lorem::paragraph }
  a.updated_at          { Factory.next(:time) }
  a.created_at          { Factory.next(:time) }
  a.contact_data        { |a| a.association(:contact_data) }
end

#------------------------------------------------------------------------------
Factory.define :deal do |a|
  a.add_attribute(:id)  { Factory.next(:id) }
  a.account_id          { Factory.next(:id) }
  a.author_id           { Factory.next(:uid) }
  a.owner_id            { Factory.next(:uid) }
  a.category_id         { Factory.next(:id) }
  a.group_id            { Factory.next(:id) }
  a.party_id            { Factory.next(:id) }
  a.reponsible_party_id { Factory.next(:id) }
  a.name                { Faker::Lorem.sentence }
  a.background          { Faker::Lorem::paragraph }
  a.status              { Faker::Lorem.sentence }
  a.currency            { Faker::Lorem.sentence }
  a.duration            { Factory.next(:id) }
  a.price               { Factory.next(:id) }
  a.price_type          { Faker::Lorem.sentence }
  a.visible_to          "Everyone"
  a.status_changed_on   { Factory.next(:date) }
  a.created_at          { Factory.next(:time) }
  a.updated_at          { Factory.next(:time) }
end

#------------------------------------------------------------------------------
Factory.define :task, :class => FatFreeCRM::Highrise::Task do |a|
  a.add_attribute(:id)  { Factory.next(:id) }
  a.author_id           { Factory.next(:uid) }
  a.owner_id            { Factory.next(:uid) }
  a.recording_id        { Factory.next(:id) }
  a.category_id         { Factory.next(:id) }
  a.subject_id          nil
  a.subject_type        nil
  a.public              true
  a.body                { Faker::Lorem::paragraph }
  a.frame               { %w(today tomorrow this_week next_week later).rand }
  a.done_at             { Factory.next(:time) }
  a.alert_at            { Factory.next(:time) }
  a.created_at          { Factory.next(:time) }
  a.updated_at          { Factory.next(:time) }
end

#------------------------------------------------------------------------------
Factory.define :note do |a|
  a.add_attribute(:id)  { Factory.next(:id) }
  a.author_id           { Factory.next(:uid) }
  a.owner_id            { Factory.next(:uid) }
  a.group_id            { Factory.next(:id) }
  a.kase_id             { Factory.next(:id) }
  a.subject_id          nil
  a.subject_type        nil
  a.body                { Faker::Lorem::paragraph }
  a.visible_to          "Everyone"
  a.created_at          { Factory.next(:time) }
  a.updated_at          { Factory.next(:time) }
end

#------------------------------------------------------------------------------
Factory.define :attachment, :class => FatFreeCRM::Highrise::Attachment do |a|
  a.add_attribute(:id)  { Factory.next(:id) }
  a.url                 { Factory.next(:website) }
  a.name                { Faker::Lorem.sentence }
  a.size                { Factory.next(:id) }
end

#------------------------------------------------------------------------------
Factory.define :email, :class => FatFreeCRM::Highrise::Email do |a|
  a.add_attribute(:id)  { Factory.next(:id) }
  a.author_id           { Factory.next(:uid) }
  a.owner_id            { Factory.next(:uid) }
  a.group_id            { Factory.next(:id) }
  a.kase_id             { Factory.next(:id) }
  a.subject_id          nil
  a.subject_type        nil
  a.title               { Faker::Lorem.sentence }
  a.body                { Faker::Lorem::paragraph }
  a.visible_to          "Everyone"
  a.created_at          { Factory.next(:time) }
  a.updated_at          { Factory.next(:time) }
end

#------------------------------------------------------------------------------
Factory.define :comment, :class => FatFreeCRM::Highrise::Comment do |a|
  a.add_attribute(:id)  { Factory.next(:id) }
  a.author_id           { Factory.next(:uid) }
  a.parent_id           { Factory.next(:id) }
  a.body                { Faker::Lorem::paragraph }
  a.created_at          { Factory.next(:time) }
end

#------------------------------------------------------------------------------
Factory.define :address do |a|
  a.add_attribute(:id)  { Factory.next(:id) }
  a.street              { Faker::Address.street_address }
  a.city                { Faker::Address.city }
  a.state               { Faker::Address.us_state_abbr }
  a.zip                 { Faker::Address.zip_code }
  a.country             "USA"
  a.location            { Factory.next(:location) }
end

#------------------------------------------------------------------------------
Factory.define :email_address do |a|
  a.add_attribute(:id)  { Factory.next(:id) }
  a.address             { Faker::Internet.email }
  a.location            { Factory.next(:location) }
end

#------------------------------------------------------------------------------
Factory.define :phone_number do |a|
  a.add_attribute(:id)  { Factory.next(:id) }
  a.number              { Faker::PhoneNumber.phone_number }
  a.location            { Factory.next(:phone_location) }
end

#------------------------------------------------------------------------------
Factory.define :instant_messenger do |a|
  a.add_attribute(:id)  { Factory.next(:id) }
  a.address             { Faker::Internet.email }
  a.protocol            { Factory.next(:protocol) }
  a.location            { Factory.next(:location) }
end

#------------------------------------------------------------------------------
Factory.define :twitter_account do |a|
  a.add_attribute(:id)  { Factory.next(:id) }
  a.username            { Factory.next(:username) }
  a.location            { Factory.next(:location) }
end

#------------------------------------------------------------------------------
Factory.define :web_address do |a|
  a.add_attribute(:id)  { Factory.next(:id) }
  a.url                 { Factory.next(:website) }
  a.location            { Factory.next(:website_location) }
end

#------------------------------------------------------------------------------
Factory.define :task_category do |a|
  a.add_attribute(:id)  { Factory.next(:id) }
  a.name                { Faker::Lorem::words(1).first }
  a.account_id          { Factory.next(:id) }
  a.elements_count      { Factory.next(:id) }
  a.created_at          { Factory.next(:time) }
  a.updated_at          { Factory.next(:time) }
end

#------------------------------------------------------------------------------
Factory.define :user, :class => FatFreeCRM::Highrise::User do |a|
  a.add_attribute(:id)  { Factory.next(:uid) }
  a.person_id           { Factory.next(:id) }
  a.name                { Factory.next(:username) }
  a.created_at          { Factory.next(:time) }
  a.updated_at          { Factory.next(:time) }
end
