require 'spec_helper'

describe Amalgamate::Unity do
  context "public methods" do
    subject { Amalgamate::Unity.new }
    it { subject.respond_to?(:unify).should be_true }
    it { subject.respond_to?(:diff).should be_true }
    it { subject.respond_to?(:differing_attributes).should be_true }
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

  describe "Merging two objects" do
    subject { Amalgamate::Unity.new(master, slave) }

    describe "#unify" do
      context "master does not have any nil attributes" do
        before do
          FactoryGirl.create(:company, name: 'Vandelay Industries', slogan: "Purveyor of Fine Latex Products", publicly_traded: false)
          FactoryGirl.create(:company, name: 'Vandelay Industries', slogan: 'Money for People', publicly_traded: true)
        end
        let(:master) { Company.first }
        let(:slave) { Company.last }
        let(:diff_hash) do
          { slogan: { master: 'Purveyor of Fine Latex Products', slave: 'Money for People' },
            publicly_traded: { master: false, slave: true }
          }
        end
        let(:update_attributes) do
          { slogan: 'Purveyor of Fine Latex Products',
            publicly_traded: false,
          }
        end

        it "finds differences using #diff" do
          subject.should_receive(:diff).with(master, slave).and_return(diff_hash)
          subject.unify
        end
        it "uses #assign_attributes to update master" do
          master.should_receive(:assign_attributes).with(update_attributes).and_return({})
          subject.unify
        end
        it "uses #changed? to determine whether to save the master" do
          master.should_receive(:changed?).and_return(false)
          master.should_not_receive(:save)
          subject.unify
        end
        it "destroys slave when merged" do
          slave.should_receive(:destroy)
          subject.unify
        end
        it "does not destroy slave if options[:destroy] is false" do
          slave.should_not_receive(:destroy)
          subject.unify(destroy: false)
        end
        it "results in one less company" do
          expect {
            subject.unify
          }.to change{ Company.count }.from(2).to(1)
        end
        it "does not overwrite false values in master" do
          subject.unify
          master.reload.publicly_traded.should == false
        end
      end

      context "use slave as :priority" do
        before do
          FactoryGirl.create(:company, name: 'Vandelay Industries', slogan: "Purveyor of Fine Latex Products")
          FactoryGirl.create(:company, name: 'The Human Fund', slogan: 'Money for People')
        end
        let(:master) { Company.first }
        let(:slave) { Company.last }
        it "should update master's name using slave's name" do
          expect {
            subject.unify(priority: :slave)
          }.to change { Company.first.name }.from('Vandelay Industries').to('The Human Fund')
        end
      end

      context "master has a nil attribute" do
        before do
          FactoryGirl.create(:company, name: 'Vandelay Industries', slogan: nil)
          FactoryGirl.create(:company, name: 'Vandelay Industries', slogan: 'Money for People')
        end
        let(:master) { Company.first }
        let(:slave) { Company.last }
        let(:diff_hash) do
          { slogan: { master: nil, slave: 'Money for People' } }
        end
        let(:update_attributes) do
          { slogan: 'Money for People' }
        end

        it "finds differences using #diff" do
          subject.should_receive(:diff).with(master, slave).and_return(diff_hash)
          subject.unify
        end
        it "uses #assign_attributes to update master" do
          master.should_receive(:assign_attributes).with(update_attributes).and_return({})
          subject.unify
        end
        it "calls #save with a changed master" do
          master.should_receive(:save).and_return(true)
          subject.unify
        end
        it "does not call #save if options[:save] is false" do
          master.should_not_receive(:save)
          subject.unify(save: false)
        end
        it "should return the merged object" do
          merged_object = subject.unify
          merged_object.should be_a Company
        end
        it "should replace nil attributes on master with slave values" do
          merged_object = subject.unify
          merged_object.slogan.should == slave.slogan
        end
      end

      context "master and slave have have_many relationships" do
        subject { Amalgamate::Unity.new(master, slave) }
        before do
          FactoryGirl.create(:company_with_employees, name: 'Vandelay Industries', employee_count: 3)
          FactoryGirl.create(:company_with_employees, name: 'The Human Fund', employee_count: 5)
        end
        let(:master) { Company.first }
        let(:slave) { Company.last }

        it { master.employees.count.should == 3}
        it { slave.employees.count.should == 5}
        it "reassigns slaves associations to master" do
          expect {
            subject.unify
          }.to change { Company.first.employees.count}.from(3).to(8)
        end
      end
    end
  end
end
