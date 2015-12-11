require 'spec_helper'

module Roper
  describe GenerateAccessToken do
    let(:client) { FactoryGirl.create(:active_record_client) }
    let(:context) { GenerateAccessToken.call(client: client) }

    context "#call" do
      context "when creating the access token succeeds" do
        it "succeeds" do
          expect(context.success?).to eq(true)
        end

        it "creates an access token" do
          context
          access_token = Roper::Repository.for(:access_token).model_class.first
          expect(access_token).not_to eq(nil)
          expect(access_token.client_id).to eq(client.id)
          expect(access_token.expires_at).not_to eq(nil)
        end

        it "sets the created access token on the context" do
          expect(context.access_token.client_id).to eq(client.id)
        end
      end

      context "when Roper.access_token_expiration_time is nil" do
        it "does not set expires_at on the access token" do
          previous_value = Roper.access_token_expiration_time
          Roper.access_token_expiration_time = nil
          context
          access_token = Roper::Repository.for(:access_token).model_class.first
          expect(access_token).not_to eq(nil)
          expect(access_token.client_id).to eq(client.id)
          expect(access_token.expires_at).to eq(nil)
          Roper.access_token_expiration_time = previous_value
        end
      end


      context "when creating the access token fails" do
        let(:stub_access_token) { double("access token") }

        before :each do
          allow(stub_access_token).to receive(:expires_at=)
          expect(stub_access_token).to receive(:save).and_return(false)
          expect(Roper::Repository.for(:access_token)).to receive(:new).and_return(stub_access_token)
        end

        it "fails" do
          expect(context.success?).to eq(false)
        end
      end
    end
  end
end
