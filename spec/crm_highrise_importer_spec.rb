require File.dirname(__FILE__) + "/spec_helper"

describe "Importing data from Highrise to Fat Free CRM" do

  # Redirect all ActiveResource requests to FakeWeb.
  before(:each) do
    FatFreeCRM::Highrise::Base.site = "http://highrise.crm"
    @backend = Fake::Backend.new
    @backend.stub(:all)
  end
  
  it "imports people as contacts" do
    @people = Person.find(:all)
    FatFreeCRM::Highrise::Import.people(@people)
    @people.each do |person|
      @imported = Contact.find_by_first_name_and_last_name(person.first_name, person.last_name)
      @imported.should_not == nil
      @imported.title.should == person.title[0..64]
      @imported.created_at.should == person.created_at
    end
  end
  
  it "imports companies as accounts" do
    @companies = Company.find(:all)
    FatFreeCRM::Highrise::Import.companies(@companies)
    @companies.each do |company|
      @imported = Account.find_by_name(company.name)
      @imported.should_not == nil
      @imported.created_at.should == company.created_at
    end
  end
    
  it "imports tasks as tasks" do
    @categories = FatFreeCRM::Highrise::TaskCategory.find(:all)
    @tasks = FatFreeCRM::Highrise::Task.find(:all)
    FatFreeCRM::Highrise::Import.tasks(@tasks, @categories)
    @tasks.each do |task|
      @imported = Task.find_by_name(task.body)
      @imported.should_not == nil
      @imported.bucket.should == "due_#{task.frame}"
      @imported.created_at.should == task.created_at
    end
  end

end

