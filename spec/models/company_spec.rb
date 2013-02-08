require 'spec_helper'

describe Company do
  it "has a valid factory" do
    FactoryGirl.build(:company).valid?.should be_true
  end
  context "company with employees" do
    before do
      FactoryGirl.create(:company_with_employees, employee_count: 3)
    end        
    subject { Company.first }
    it "builds a company with 3 employees", focus: true do
      subject.employees.size.should == 3
    end
  end
end
