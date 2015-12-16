require 'spec_helper'

module Roper
  describe GenerateRefreshToken do
    let(:client) { FactoryGirl.create(:active_record_client) }
    let(:context) { GenerateRefreshToken.call(client: client) }

    context "#call" do
      context "when creating the refresh token succeeds" do
        it "succeeds" do
          expect(context.success?).to eq(true)
        end

        it "creates a refresh token" do
          context
          refresh_token = Roper::Repository.for(:refresh_token).model_class.first
          expect(refresh_token).not_to eq(nil)
          expect(refresh_token.client_id).to eq(client.id)
          expect(refresh_token.token).to match(/[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/)
        end
      end
    end
  end
end
