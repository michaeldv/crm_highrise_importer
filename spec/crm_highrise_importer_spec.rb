require File.dirname(__FILE__) + "/spec_helper"

describe "Importing data from Highrise to Fat Free CRM" do

  # Redirect all ActiveResource requests to FakeWeb.
  before(:each) do
    FatFreeCRM::Highrise::Base.site = "http://highrise.crm"
    @backend = Fake::Backend.new
    @backend.stub(:all)
    Import.users
    Import.categories
  end

  it "imports users" do
    exported, imported = Import.users, Import.fat_free_crm_users
    exported.size.should == imported.size
    exported.zip(imported).each do |ex, im|
       im.username.should == ex.name
       im.email.should =~ /^.+?@.+$/
       im.created_at.should == ex.created_at
       im.password_hash.should_not == nil
    end
  end
  
  it "imports people as contacts" do
    people, contacts = Import.people
    people.size.should == contacts.size
    people.zip(contacts).each do |person, contact|
      contact.user_id.should_not == nil
      contact.assigned_to.should == nil if person.owner_id.nil?
      contact.assigned_to.should_not == nil unless person.owner_id.nil?
      contact.first_name.should == person.first_name[0..63]
      contact.last_name.should == person.last_name[0..63]
      contact.title.should == person.title[0..63]
      contact.created_at.should == person.created_at
    end
  end
  
  it "imports companies as accounts" do
    companies, accounts = Import.companies
    companies.size.should == accounts.size
    companies.zip(accounts).each do |company, account|
      account.user_id.should_not == nil
      account.assigned_to.should == nil if company.owner_id.nil?
      account.assigned_to.should_not == nil unless company.owner_id.nil?
      account.name.should == company.name[0..63]
      account.created_at.should == company.created_at
    end
  end
  
  it "imports related tasks for contacts" do
    people, contacts = Import.people
    exported, imported = Import.related_tasks(people, contacts)
    exported.size.should == imported.size
    exported.zip(imported).each do |ex, im|
      im.name.should == ex.body[0..254]
      im.asset_id.should_not == nil
      im.asset_type.should == "Contact"
      im.bucket.should == "due_#{ex.frame}"
      im.created_at.should == ex.created_at
    end
  end
  
  it "imports related tasks for companies" do
    companies, accounts = Import.companies
    exported, imported = Import.related_tasks(companies, accounts)
    exported.size.should == imported.size
    exported.zip(imported).each do |ex, im|
      im.name.should == ex.body[0..254]
      im.asset_id.should_not == nil
      im.asset_type.should == "Account"
      im.bucket.should == "due_#{ex.frame}"
      im.created_at.should == ex.created_at
    end
  end

  it "imports unrelated tasks" do
    exported, imported = Import.unrelated_tasks
    exported.size.should == imported.size
    exported.zip(imported).each do |ex, im|
      im.name.should == ex.body[0..254]
      im.asset_id.should == nil
      im.asset_type.should == nil
      im.bucket.should == "due_#{ex.frame}"
      im.created_at.should == ex.created_at
    end
  end

end

