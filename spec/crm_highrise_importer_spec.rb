require File.dirname(__FILE__) + "/spec_helper"

describe "Looks good" do
  before(:each) do
    Highrise::Base.site = "http://highrise.crm" # Redirect all ActiveResource requests to FakeWeb.
  end

  it "Factory(:contact_data)" do
    @contact_data = Factory(:contact_data)
    puts @contact_data.to_xml
    puts @contact_data.inspect
    true
  end
  
  it "Factory(:person)" do
    @person = Factory(:person)
    puts @person.to_xml
    puts @person.inspect
    true
  end

  it "Backend(:people)" do
    Backend(:people)
    @people = Person.find(:all)
    puts @people.inspect
    true
  end

  it "Backend(:companies)" do
    Backend(:companies)
    @companies = Company.find(:all)
    puts @companies.inspect
    true
  end
end

