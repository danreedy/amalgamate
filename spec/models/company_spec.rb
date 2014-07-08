require 'spec_helper'

describe Company do
  context "class methods" do
    subject { Company }
    its(:can_be_merged?) { should be_true }
  end
  it "has a valid factory" do
    FactoryGirl.build(:company).valid?.should be_true
  end
  context "company with employees" do
    before do
      FactoryGirl.create(:company_with_employees, employee_count: 3)
    end
    subject { Company.first }
    it "builds a company with 3 employees" do
      subject.employees.size.should == 3
    end
  end
  context "company with headquarter" do
    it "creates a headquarter" do
      expect {
        FactoryGirl.create(:company_with_headquarter)
      }.to change { Headquarter.count }.by(1)
    end
  end
  describe "amalgamate extensions", focus: true do
    it { subject.respond_to?(:unify).should be_true }
    it { subject.respond_to?(:diff).should be_true }
    describe "#diff" do
      subject { master }
      let(:master) { FactoryGirl.create(:company, name: 'Vandelay Industries', slogan: nil) }
      let(:slave) { FactoryGirl.create(:company, name: 'The Human Fund', slogan: 'Money for Peope') }
    end
  end
end
