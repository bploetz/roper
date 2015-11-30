require "spec_helper"
require 'roper/repository/active_record'

describe Roper::ActiveRecord::Client do
  context "#valid_redirect_uri?" do
    let(:client) do
      client = FactoryGirl.build(:active_record_client)
      client.client_redirect_uris << FactoryGirl.build(:active_record_client_redirect_uri)
      client
    end

    it "returns true if a given uri is found in the set of associated redirect URIs" do
      expect(client.valid_redirect_uri?(client.client_redirect_uris[0].uri)).to eq(true)
    end

    it "returns true ignoring case" do
      expect(client.valid_redirect_uri?(client.client_redirect_uris[0].uri.upcase)).to eq(true)
    end

    it "returns false if a given uri has a query string not found on an associated redirect URIs " do
      expect(client.valid_redirect_uri?(client.client_redirect_uris[0].uri + "?foo=bar&hi=mom")).to eq(false)
    end

    it "returns false if a given uri is not found in the set of associated redirect URIs" do
      expect(client.valid_redirect_uri?("foo")).to eq(false)
    end
  end
end
