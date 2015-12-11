require 'spec_helper'

module Roper
  describe GenerateAccessToken do
    let(:client) { FactoryGirl.create(:active_record_client) }
    let(:context) { GenerateAccessToken.call(client: client) }

    context "#call" do
     let(:stub_access_token) { double("access token") }

      before :each do
        expect(Roper::Repository.for(:access_token)).to receive(:new).and_return(stub_access_token)
      end

      context "when creating the access token succeeds" do
        before :each do
          expect(stub_access_token).to receive(:save).and_return(true)
        end

        it "succeeds" do
          expect(context.success?).to eq(true)
        end
      end

      context "when creating the access token fails" do
        before :each do
          expect(stub_access_token).to receive(:save).and_return(false)
        end

        it "fails" do
          expect(context.success?).to eq(false)
        end
      end
    end
  end
end
