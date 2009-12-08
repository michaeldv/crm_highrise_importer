require File.dirname(__FILE__) + "/spec_helper"

describe "Importing data from Highrise to Fat Free CRM" do

  # Redirect all ActiveResource requests to FakeWeb.
  before(:each) do
    FatFreeCRM::Highrise::Base.site = "http://highrise.crm"
    @backend = Fake::Backend.new
    @backend.stub(:all)
  end
  
  it "imports people as contacts" do
    @people = Import.people
    @people.each do |person|
      @imported = Contact.find_by_first_name_and_last_name(person.first_name, person.last_name)
      @imported.should_not == nil
      @imported.title.should == person.title[0..64]
      @imported.created_at.should == person.created_at
    end
  end
  
  it "imports companies as accounts" do
    @companies = Import.companies
    @companies.each do |company|
      @imported = Account.find_by_name(company.name)
      @imported.should_not == nil
      @imported.created_at.should == company.created_at
    end
  end

  it "imports related tasks for contacts" do
    Import.categories
    @people = Import.people
    @tasks = [
      Factory(:task, :subject_id => @people.first.id, :subject_type => "Person"),
      Factory(:task, :subject_id => @people.first.id, :subject_type => "Person")
    ]
    @tasks.each do |task|
      @imported = Task.find_by_name(task.body)
      @imported.should_not == nil
      @imported.asset_id.should == @people.first.id
      @imported.asset_type.should == "Contact"
      @imported.bucket.should == "due_#{task.frame}"
      @imported.created_at.to_s(:db).should == task.created_at.to_s(:db)
    end
  end

  it "imports related tasks for companies" do
    Import.categories
    @companies = Import.companies
    @tasks = [
      Factory(:task, :subject_id => @companies.first.id, :subject_type => "Company"),
      Factory(:task, :subject_id => @companies.first.id, :subject_type => "Company")
    ]
    @tasks.each do |task|
      @imported = Task.find_by_name(task.body)
      @imported.should_not == nil
      @imported.asset_id.should == @companies.first.id
      @imported.asset_type.should == "Account"
      @imported.bucket.should == "due_#{task.frame}"
      @imported.created_at.to_s(:db).should == task.created_at.to_s(:db)
    end
  end

  it "imports unrelated tasks" do
    @tasks = Import.tasks
    @tasks.each do |task|
      @imported = Task.find_by_name(task.body)
      @imported.should_not == nil
      @imported.bucket.should == "due_#{task.frame}"
      @imported.created_at.to_s(:db).should == task.created_at.to_s(:db)
    end
  end

end

