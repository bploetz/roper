require 'spec_helper'

module Roper
  describe ValidateRefreshToken do
    let(:client) { FactoryGirl.create(:active_record_client) }
    let(:access_token) { FactoryGirl.create(:active_record_access_token, client: client) }
    let(:context) { ValidateRefreshToken.call(client: client, refresh_token: access_token.refresh_token) }

    context "#call" do
      context "refresh token is not found" do
        let(:context) { ValidateRefreshToken.call(client: client, refresh_token: "foo") }

        it "fails" do
          expect(context.success?).to eq(false)
        end
      end

      context "authorization code not associated with client in the request" do
        let(:another_client) { FactoryGirl.create(:active_record_client, :client_id => "hi  ", :client_secret => "hi") }
        let(:access_token) { FactoryGirl.create(:active_record_access_token, client: another_client) }

        it "fails" do
          expect(context.success?).to eq(false)
        end
      end
    end
  end
end
