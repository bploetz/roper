require "spec_helper"

describe Roper::Mongoid::JwtIssuerKey do
  let(:client) { FactoryGirl.create(:mongoid_client, :client_secret => "foo") }

  context "validation" do
    it "validates algorithm is present" do
      jwt_issuer_key = FactoryGirl.build(:mongoid_jwt_issuer_key, :algorithm => nil)
      expect(jwt_issuer_key.valid?).to eq(false)
      expect(jwt_issuer_key.errors.messages[:algorithm][0]).to eq("can't be blank")
    end

    it "validates hmac_secret is present if algorithm is HMAC" do
      jwt_issuer_key = FactoryGirl.build(:mongoid_jwt_issuer_key, :hmac_secret => nil)
      expect(jwt_issuer_key.valid?).to eq(false)
      expect(jwt_issuer_key.errors.messages[:hmac_secret][0]).to eq("can't be blank")
    end

    it "validates public_key is present if algorithm is RSA" do
      jwt_issuer_key = FactoryGirl.build(:mongoid_jwt_issuer_key, :algorithm => "RS256", :public_key => nil)
      expect(jwt_issuer_key.valid?).to eq(false)
      expect(jwt_issuer_key.errors.messages[:public_key][0]).to eq("can't be blank")
    end

    it "validates public_key is present if algorithm is ECDSA" do
      jwt_issuer_key = FactoryGirl.build(:mongoid_jwt_issuer_key, :algorithm => "ES256", :public_key => nil)
      expect(jwt_issuer_key.valid?).to eq(false)
      expect(jwt_issuer_key.errors.messages[:public_key][0]).to eq("can't be blank")
    end

    it "allows valid algorithms" do
      jwt_issuer_key = FactoryGirl.build(:mongoid_jwt_issuer_key)
      expect(jwt_issuer_key.valid?).to eq(true)
    end

    it "blocks invalid algorithms" do
      jwt_issuer_key = FactoryGirl.build(:mongoid_jwt_issuer_key, :algorithm => "foo")
      expect(jwt_issuer_key.valid?).to eq(false)
      expect(jwt_issuer_key.errors.messages[:algorithm][0]).to eq("foo is not a supported algorithm")
    end

    context "RSA algorithm" do
      let(:rsa_keypair) { OpenSSL::PKey::RSA.generate 2048 }

      it "validates that the key is an OpenSSL::PKey::RSA object" do
        Roper::Mongoid::JwtIssuerKey::RSA_ALGORITHMS.each do |algo|
          jwt_issuer_key = FactoryGirl.build(:mongoid_jwt_issuer_key, :algorithm => algo, :public_key => 1)
          expect(jwt_issuer_key.valid?).to eq(false)
          expect(jwt_issuer_key.errors.messages[:public_key][0]).to eq("must be an OpenSSL::PKey::RSA object for #{algo} algorithm")
        end
      end

      it "validates that the key is not an OpenSSL::PKey::RSA private key" do
        Roper::Mongoid::JwtIssuerKey::RSA_ALGORITHMS.each do |algo|
          jwt_issuer_key = FactoryGirl.build(:mongoid_jwt_issuer_key, :algorithm => algo, :public_key => rsa_keypair)
          expect(jwt_issuer_key.valid?).to eq(false)
          expect(jwt_issuer_key.errors.messages[:public_key][0]).to eq("must not be a private key")
        end
      end
    end

    context "ECDSA algorithm" do
      let(:ecdsa_keypair) do
        ecdsa_key = OpenSSL::PKey::EC.new 'prime256v1'
        ecdsa_key.generate_key
      end

      it "validates that the key is an OpenSSL::PKey::EC object" do
        Roper::Mongoid::JwtIssuerKey::ECDSA_ALGORITHMS.each do |algo|
          jwt_issuer_key = FactoryGirl.build(:mongoid_jwt_issuer_key, :algorithm => algo, :public_key => 1)
          expect(jwt_issuer_key.valid?).to eq(false)
          expect(jwt_issuer_key.errors.messages[:public_key][0]).to eq("must be an OpenSSL::PKey::EC object for #{algo} algorithm")
        end
      end

      it "validates that the key is not an OpenSSL::PKey::EC private key" do
        Roper::Mongoid::JwtIssuerKey::ECDSA_ALGORITHMS.each do |algo|
          jwt_issuer_key = FactoryGirl.build(:mongoid_jwt_issuer_key, :algorithm => algo, :public_key => ecdsa_keypair)
          expect(jwt_issuer_key.valid?).to eq(false)
          expect(jwt_issuer_key.errors.messages[:public_key][0]).to eq("must not be a private key")
        end
      end
    end
  end

  context "callbacks" do
    context "before_save" do
      context "RSA algorithm" do
        let(:rsa_keypair) { OpenSSL::PKey::RSA.generate 2048 }
        let(:rsa_public_key) { rsa_keypair.public_key }
        let(:jwt_issuer) { FactoryGirl.create(:mongoid_jwt_issuer, :client => client) }

        it "serializes the key to PEM format" do
          Roper::Mongoid::JwtIssuerKey::RSA_ALGORITHMS.each do |algo|
            jwt_issuer.jwt_issuer_keys << FactoryGirl.build(:mongoid_jwt_issuer_key, :algorithm => algo, :public_key => rsa_public_key)
            saved_client = Roper::Mongoid::Client.find(client.id)
            saved_jwt_issuer = saved_client.jwt_issuers.first
            saved_jwt_issuer_key = saved_jwt_issuer.jwt_issuer_keys.first
            expect(saved_jwt_issuer_key.public_key).to eq(rsa_public_key.to_pem)
          end
        end
      end

      context "ECDSA algorithm" do
        let(:ecdsa_keypair) do
          keypair = OpenSSL::PKey::EC.new 'prime256v1'
          keypair.generate_key
          keypair
        end
        let(:ecdsa_public_key) do
          public_key = OpenSSL::PKey::EC.new ecdsa_keypair
          public_key.private_key = nil
          public_key
        end
        let(:jwt_issuer) { FactoryGirl.create(:mongoid_jwt_issuer, :client => client) }

        it "serializes the key to PEM format" do
          Roper::Mongoid::JwtIssuerKey::ECDSA_ALGORITHMS.each do |algo|
            jwt_issuer.jwt_issuer_keys << FactoryGirl.build(:mongoid_jwt_issuer_key, :algorithm => algo, :public_key => ecdsa_public_key)
            saved_client = Roper::Mongoid::Client.find(client.id)
            saved_jwt_issuer = saved_client.jwt_issuers.first
            saved_jwt_issuer_key = saved_jwt_issuer.jwt_issuer_keys.first
            expect(saved_jwt_issuer_key.public_key).to eq(ecdsa_public_key.to_pem)
          end
        end
      end
    end
  end
end
