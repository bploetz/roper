require "spec_helper"

describe Roper::Mongoid::Client do
  context "validations" do
    let(:client) { FactoryGirl.create(:mongoid_client) }

    it "validates client_id is unique" do
      client
      client2 = FactoryGirl.build(:mongoid_client)
      expect(client2.save).to eq(false)
      expect(client2.errors[:client_id]).to eq(["client_id has already been taken"])
    end

    it "doesn't allow client_id to be changed after being created" do
      saved_client = Roper::Mongoid::Client.find_by(client_id: client.client_id)
      saved_client.client_id = "foo"
      expect(saved_client.save).to eq(false)
      expect(saved_client.errors[:client_id]).to eq(["cannot update client_id"])
    end

    it "doesn't allow client_secret to be changed after being created" do
      saved_client = Roper::Mongoid::Client.find_by(client_id: client.client_id)
      saved_client.client_secret = "foo"
      expect(saved_client.save).to eq(false)
      expect(saved_client.errors[:client_secret]).to eq(["cannot update client_secret"])
    end
  end

  context "callbacks" do
    let(:client) { FactoryGirl.create(:mongoid_client, :client_secret => "foo") }

    context "before_save" do
      it "bcrypts the client_secret" do
        expect(client.client_secret).not_to eq("foo")
        expect(BCrypt::Password.new(client.client_secret) == "foo").to eq(true)
      end
    end
  end

  context "#valid_redirect_uri?" do
    let(:client) do
      client = FactoryGirl.build(:mongoid_client)
      client.client_redirect_uris << FactoryGirl.build(:mongoid_client_redirect_uri)
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
