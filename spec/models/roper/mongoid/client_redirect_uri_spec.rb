require "spec_helper"

describe Roper::Mongoid::ClientRedirectUri do
  context "validation" do
    it "allows valid URIs" do
      client_redirect_uri = FactoryGirl.build(:mongoid_client_redirect_uri)
      expect(client_redirect_uri.valid?).to eq(true)
    end

    it "blocks invalid URIs" do
      client_redirect_uri = FactoryGirl.build(:mongoid_client_redirect_uri, :uri => "buh")
      expect(client_redirect_uri.valid?).to eq(false)
    end
  end
end
