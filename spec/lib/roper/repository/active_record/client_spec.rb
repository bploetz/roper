require "spec_helper"
require 'roper/repository/active_record'

describe Roper::ActiveRecord::Client do

  context "validations" do
    let(:client) { FactoryGirl.create(:active_record_client) }

    it "validates client_id is unique" do
      client
      client2 = FactoryGirl.build(:active_record_client)
      expect(client2.save).to eq(false)
      expect(client2.errors[:client_id]).to eq(["client_id has already been taken"])
    end

    it "doesn't allow client_id to be changed after being created" do
      saved_client = Roper::ActiveRecord::Client.find_by_client_id(client.client_id)
      saved_client.client_id = "foo"
      expect(saved_client.save).to eq(false)
      expect(saved_client.errors[:client_id]).to eq(["cannot update client_id"])
    end

    it "doesn't allow client_secret to be changed after being created" do
      saved_client = Roper::ActiveRecord::Client.find_by_client_id(client.client_id)
      saved_client.client_secret = "foo"
      expect(saved_client.save).to eq(false)
      expect(saved_client.errors[:client_secret]).to eq(["cannot update client_secret"])
    end
  end

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
