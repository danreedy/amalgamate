require 'spec_helper'

describe Company do
  it "has a valid factory" do
    FactoryGirl.build(:company).valid?.should be_true
  end
end
