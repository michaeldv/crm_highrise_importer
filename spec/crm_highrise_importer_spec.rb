require File.dirname(__FILE__) + "/spec_helper"

describe "Importing data from Highrise to Fat Free CRM" do

  before(:each) do
    FatFreeCRM::Highrise::Base.site = "http://highrise.crm" # Redirect all ActiveResource requests to FakeWeb.
  end

  it "Factory(:contact_data)" do
    @contact_data = Factory(:contact_data)
    puts @contact_data.to_xml
    puts @contact_data.inspect
  end
  
  it "Factory(:person)" do
    @person = Factory(:person)
    puts @person.to_xml
    puts @person.inspect
  end
  
  it "Backend(:people)" do
    Backend(:people)
    @people = Person.find(:all)
    puts @people.inspect
  end
  
  it "Backend(:companies)" do
    Backend(:companies)
    @companies = Company.find(:all)
    puts @companies.inspect
  end

  it "imports people as contacts" do
    Backend(:company)
    Backend(:people)
    @people = Person.find(:all)
    FatFreeCRM::Highrise::Import.people(@people)
  end

end

