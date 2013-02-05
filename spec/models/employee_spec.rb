require 'spec_helper'

describe Employee do
  it "has a valid factory" do
    FactoryGirl.build(:employee).valid?.should be_true
  end
end
