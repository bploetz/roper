require 'spec_helper'

module Roper
  describe RedeemAuthorizationCode do
    let(:client) { FactoryGirl.create(:active_record_client, :client_id => "test", :client_secret => "test") }
    let(:authorization_code) { FactoryGirl.create(:active_record_authorization_code, :client => client) }
    let(:context) { RedeemAuthorizationCode.call(authorization_code: authorization_code) }

    context "#call" do
      context "when updating the authorization_code succeeds" do
        before :each do
          expect(authorization_code).to receive(:redeemed=).with(true)
          expect(authorization_code).to receive(:save).and_return(true)
        end

        it "succeeds" do
          expect(context.success?).to eq(true)
        end
      end

      context "when updating the authorization_code fails" do
        before :each do
          expect(authorization_code).to receive(:redeemed=).with(true)
          expect(authorization_code).to receive(:save).and_return(false)
        end

        it "fails" do
          expect(context.success?).to eq(false)
        end
      end
    end
  end
end
