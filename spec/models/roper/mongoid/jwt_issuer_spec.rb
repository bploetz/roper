require "spec_helper"

describe Roper::Mongoid::JwtIssuer do
  context "validations" do
    let(:client) { FactoryGirl.create(:mongoid_client, :client_secret => "foo") }
    let(:jwt_issuer) { FactoryGirl.create(:mongoid_jwt_issuer, :client => client) }

    it "validates algorithm only appears once in the list" do
      jwt_issuer.jwt_issuer_keys.build(:algorithm => "HS256", :hmac_secret => "shhh")
      expect(jwt_issuer.valid?).to eq(true)
      jwt_issuer.jwt_issuer_keys.build(:algorithm => "HS256", :hmac_secret => "shhh2")
      expect(jwt_issuer.valid?).to eq(false)
      expect(jwt_issuer.errors[:jwt_issuer_keys]).to eq(["may not contain duplicate algorithms"])
    end
  end
end
