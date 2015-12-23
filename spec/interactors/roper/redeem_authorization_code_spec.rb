require 'spec_helper'

module Roper
  describe RedeemAuthorizationCode do
    let(:client) { FactoryGirl.create(:active_record_client, :client_id => "test", :client_secret => "test") }
    let(:authorization_code) { FactoryGirl.create(:active_record_authorization_code, :client => client, :redeemed => false) }
    let(:context) { RedeemAuthorizationCode.call(code: authorization_code.code) }

    context "#call" do
      context "authorization_code has already been redeemed" do
        let(:authorization_code) { FactoryGirl.create(:active_record_authorization_code, :client => client, :redeemed => true) }

        it "fails" do
          expect(context.success?).to eq(false)
        end
      end

      context "when updating the authorization_code succeeds" do
        it "succeeds" do
          expect(context.success?).to eq(true)
        end

        it "sets redeemed to true" do
          context
          updated_authorization_code = Roper::Repository.for(:authorization_code).find_by_code(authorization_code.code)
          expect(updated_authorization_code.redeemed).to eq(true)
        end
      end

      context "when updating the authorization_code fails" do
        before :each do
          expect_any_instance_of(Roper::ActiveRecord::AuthorizationCode).to receive(:save).and_return(false)
        end

        it "fails" do
          expect(context.success?).to eq(false)
        end
      end
    end
  end
end
