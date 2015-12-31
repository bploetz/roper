require "spec_helper"

describe Roper::ActiveRecord::JwtIssuer do
  context "validations" do
    let(:jwt_issuer) { FactoryGirl.create(:active_record_jwt_issuer) }

    it "validates client_id is unique" do
      jwt_issuer
      jwt_issuer2 = FactoryGirl.build(:active_record_jwt_issuer, :issuer => jwt_issuer.issuer)
      expect(jwt_issuer2.save).to eq(false)
      expect(jwt_issuer2.errors[:issuer]).to eq(["issuer has already been taken"])
    end

    it "validates algorithm only appears once in the list" do
      jwt_issuer.jwt_issuer_keys.build(:algorithm => "HS256", :hmac_secret => "shhh")
      expect(jwt_issuer.valid?).to eq(true)
      jwt_issuer.jwt_issuer_keys.build(:algorithm => "HS256", :hmac_secret => "shhh2")
      expect(jwt_issuer.valid?).to eq(false)
      expect(jwt_issuer.errors[:jwt_issuer_keys]).to eq(["may not contain duplicate algorithms"])
    end
  end
end
