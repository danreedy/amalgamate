require 'spec_helper'

describe Headquarter do
  it "has a valid factory" do
    FactoryGirl.build(:headquarter).valid?.should be_true
  end
end
