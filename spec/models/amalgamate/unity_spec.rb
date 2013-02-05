require 'spec_helper'

describe Amalgamate::Unity do
  context "public methods" do
    subject { Amalgamate::Unity.new }
    it { subject.respond_to?(:unify).should be_true }
    it { subject.respond_to?(:combine).should be_true }
    it { subject.respond_to?(:diff).should be_true }
  end

  describe "Finding Differences using #diff and #differing_attributes" do
    subject { Amalgamate::Unity.new(master, slave) }

    context "mismatched classes for master and slave" do
      let(:master) { FactoryGirl.build(:company) }
      let(:slave) { FactoryGirl.build(:employee) }
      it "raises ClassMismatchError" do
        expect { subject.diff }.to raise_error(Amalgamate::ClassMismatchError)
      end
    end

    context "matching classes" do
      let(:master) { FactoryGirl.build(:company, name: 'Vandelay Industries', slogan: nil) }
      
      context "multiple attributes are different" do
        let(:slave) { FactoryGirl.build(:company, name: 'The Human Fund', slogan: 'Money for People') }
        let(:difference_hash) do
          {
            name: { master: 'Vandelay Industries', slave: 'The Human Fund' },
            slogan: { master: nil, slave: 'Money for People' }
          }
        end
        describe "#diff" do
          its(:diff) { should == difference_hash }
          it "should return 2 differences" do
            subject.diff.count.should == 2
          end
        end
        describe "#differing_attributes" do
          let(:difference_array) { [:name, :slogan] }
          it "references #diff when #differing_attributes is called" do
            subject.should_receive(:diff).with(master, slave).and_return(difference_hash)
            subject.differing_attributes  
          end
          its(:differing_attributes) { should == difference_array }
        end
      end

      context "a single attribute is different" do
        let(:slave) { FactoryGirl.build(:company, name: 'Vandelay Industries', slogan: 'Money for People') }
        let(:difference_hash) do
          {
            slogan: { master: nil, slave: 'Money for People' }
          }
        end
        describe "#diff" do
          its(:diff) { should == difference_hash }
          it "should return 1 difference" do
            subject.diff.count.should == 1          
          end
        end
        describe "#differing_attributes" do
          let(:difference_array) { [:slogan] }
          its(:differing_attributes) { should == difference_array }
        end
      end
    end
  end
end
