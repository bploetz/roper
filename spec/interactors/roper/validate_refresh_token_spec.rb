require 'spec_helper'

module Roper
  describe ValidateRefreshToken do
    let(:client) { FactoryGirl.create(:active_record_client) }
    let(:refresh_token) { FactoryGirl.create(:active_record_refresh_token, client: client) }
    let(:context) { ValidateRefreshToken.call(client: client, refresh_token: refresh_token.token) }

    context "#call" do
      context "refresh token is not found" do
        let(:context) { ValidateRefreshToken.call(client: client, refresh_token: "foo") }

        it "fails" do
          expect(context.success?).to eq(false)
        end
      end

      context "refresh token not associated with client in the request" do
        let(:another_client) { FactoryGirl.create(:active_record_client, :client_id => "hi  ", :client_secret => "hi") }
        let(:refresh_token) { FactoryGirl.create(:active_record_refresh_token, client: another_client) }

        it "fails" do
          expect(context.success?).to eq(false)
        end
      end
    end
  end
end
