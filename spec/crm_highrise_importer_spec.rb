require File.dirname(__FILE__) + "/spec_helper"

describe "Importing data from Highrise to Fat Free CRM" do

  before(:each) do
    FatFreeCRM::Highrise::Base.site = "http://highrise.crm" # Redirect all ActiveResource requests to FakeWeb.
  end

  describe "Basic factories" do
    it "Factory(:contact_data)" do
      @contact_data = Factory(:contact_data)
      @contact_data.class.should == FatFreeCRM::Highrise::ContactData
    end
  
    it "Factory(:person)" do
      @person = Factory(:person)
      @person.class.should == FatFreeCRM::Highrise::Person
    end
  
    it "Factory(:company)" do
      @company = Factory(:company)
      @company.class.should == FatFreeCRM::Highrise::Company
    end
      
    it "Backend(:person)" do
      Backend(:person)
      @people = Person.find(:all)
      @people.class.should == Array
      @people.first.class.should == FatFreeCRM::Highrise::Person
    end
      
    it "Backend(:company)" do
      Backend(:company)
      @companies = Company.find(:all)
      @companies.class.should == Array
      @companies.first.class.should == FatFreeCRM::Highrise::Company
    end
  end

  describe "Importing" do
    before(:each) do
      [ :person, :company ].each do |entity|
        Backend(entity)
      end
      @people = Person.find(:all)
      FatFreeCRM::Highrise::Import.people(@people)
    end
  
    it "imports people as contacts" do
      @people.each do |person|
        @contact = Contact.find_by_first_name_and_last_name(person.first_name, person.last_name)
        @contact.should_not == nil
      end
    end
  end

end

