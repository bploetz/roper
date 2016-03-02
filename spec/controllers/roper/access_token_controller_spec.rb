require 'spec_helper'

module Roper
  describe AccessTokenController do
    routes { Roper::Engine.routes }

    let!(:client) { FactoryGirl.create(:active_record_client, :client_id => "test", :client_secret => "test") }
    let(:current_user) { double("current_user") }

    before :each do
      allow(current_user).to receive(:id).and_return("abc123")
      allow(controller).to receive(:current_user).and_return(current_user)
    end

    describe "authenticate_client filter" do
      context "basic authentication" do
        context "invalid client_id" do
          before :each do
            @request.env["HTTP_AUTHORIZATION"] = "Basic #{::Base64.strict_encode64("foo:bar")}"
            post :token, {}
          end

          it "returns a 401" do
            expect(response.code).to eq("401")
          end

          it "sets the WWW-Authenticate header" do
            expect(response.headers).to include("WWW-Authenticate")
          end
        end

        context "client_secret doesn't match" do
          before :each do
            @request.env["HTTP_AUTHORIZATION"] = "Basic #{::Base64.strict_encode64("test:bar")}"
            post :token, {}
          end

          it "returns a 401" do
            expect(response.code).to eq("401")
          end

          it "sets the WWW-Authenticate header" do
            expect(response.headers["WWW-Authenticate"]).to eq("Basic")
          end

          it "returns an invalid_client error response" do
            expect(response.body).to eq("{\"error\":\"invalid_client\"}")
          end
        end

        it "allows clients with valid basic auth credentials" do
          authorization_code = FactoryGirl.create(:active_record_authorization_code, :client => client)
          @request.env["HTTP_AUTHORIZATION"] = "Basic #{::Base64.strict_encode64("test:test")}"
          post :token, {:grant_type => "authorization_code", :code => authorization_code.code}
          expect(response.code).to eq("200")
        end
      end

      context "client_id request param" do
        context "grant_type=authorization_code" do
          let(:authorization_code) { FactoryGirl.create(:active_record_authorization_code, :client => client) }

          context "client_id not found" do
            before :each do
              post :token, {:grant_type => "authorization_code", :code => authorization_code.code, :client_id => "foo"}
            end

            it "returns a 400" do
              expect(response.code).to eq("400")
            end

            it "returns an invalid_client error response" do
              expect(response.body).to eq("{\"error\":\"invalid_client\"}")
            end
          end

          context "client_id found" do
            it "allows client" do
              authorization_code = FactoryGirl.create(:active_record_authorization_code, :client => client)
              post :token, {:grant_type => "authorization_code", :code => authorization_code.code, :client_id => client.client_id}
              expect(response.code).to eq("200")
            end
          end
        end

        context "grant_type != authorization_code" do
          it "returns a 401" do
            post :token, {:grant_type => "password", :client_id => "foo"}
            expect(response.code).to eq("401")
          end
        end
      end

      context "neither basic auth nor client_id" do
        it "returns a 401" do
          post :token, {:grant_type => "authorization_code", :code => "foo"}
          expect(response.code).to eq("401")
        end
      end
    end

    describe "POST /oauth/token" do
      before :each do
        @request.env["HTTP_AUTHORIZATION"] = "Basic #{::Base64.strict_encode64("test:test")}"
      end

      context "grant_type parameter is missing" do
        before :each do
          post :token, {}
        end

        it "returns a 400 status code" do
          expect(response.code).to eq("400")
        end

        it "returns an invalid_request error response" do
          expect(response.body).to eq("{\"error\":\"invalid_request\"}")
        end
      end

      context "grant_type parameter is unsupported" do
        before :each do
          post :token, {:grant_type => "foo"}
        end

        it "returns a 400 status code" do
          expect(response.code).to eq("400")
        end

        it "returns an unsupported_grant_type error response" do
          expect(response.body).to eq("{\"error\":\"unsupported_grant_type\"}")
        end
      end

      context "grant_type=authorization_code" do
        context "ValidateAuthorizationCode fails" do
          before :each do
            failed_result = double("fail")
            expect(failed_result).to receive(:success?).and_return(false)
            allow(failed_result).to receive(:message)
            Roper::ValidateAuthorizationCode.stub(:call).and_return(failed_result)
            post :token, {:grant_type => "authorization_code", :code => "foo"}
          end

          it "returns a 400 status code" do
            expect(response.code).to eq("400")
          end

          it "returns an invalid_grant error response" do
            expect(response.body).to eq("{\"error\":\"invalid_grant\"}")
          end
        end

        context "authorization code with redirect_uri" do
          let(:authorization_code) { FactoryGirl.create(:active_record_authorization_code, :client => client, :redirect_uri => "http://www.google.com") }

          it "returns a 200 status code" do
            post :token, {:grant_type => "authorization_code", :code => authorization_code.code, :redirect_uri => authorization_code.redirect_uri}
            expect(response.code).to eq("200")
          end

          it "returns an access token response" do
            post :token, {:grant_type => "authorization_code", :code => authorization_code.code, :redirect_uri => authorization_code.redirect_uri}
            expect(response.body).to match(/{"access_token":"[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}","token_type":"Bearer","expires_in":900}/)
          end

          it "generates an access code" do
            expect(Roper::GenerateAccessToken).to receive(:call).and_call_original
            post :token, {:grant_type => "authorization_code", :code => authorization_code.code, :redirect_uri => authorization_code.redirect_uri}
          end

          xit "sets the current user on the access token" do
            expect(Roper::GenerateAccessToken).to receive(:call).with(hash_including(:principal => "abc123")).and_call_original
            post :token, {:grant_type => "authorization_code", :code => authorization_code.code, :redirect_uri => authorization_code.redirect_uri}
          end

          it "redeems the authorization code" do
            expect(Roper::RedeemAuthorizationCode).to receive(:call).and_call_original
            post :token, {:grant_type => "authorization_code", :code => authorization_code.code, :redirect_uri => authorization_code.redirect_uri}
          end
        end

        context "authorization code without redirect_uri" do
          let(:authorization_code) { FactoryGirl.create(:active_record_authorization_code, :client => client) }

          it "returns a 200 status code" do
            post :token, {:grant_type => "authorization_code", :code => authorization_code.code}
            expect(response.code).to eq("200")
          end

          it "returns an access token response" do
            post :token, {:grant_type => "authorization_code", :code => authorization_code.code}
            expect(response.body).to match(/{"access_token":"[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}","token_type":"Bearer","expires_in":900}/)
          end

          it "generates an access code" do
            expect(Roper::GenerateAccessToken).to receive(:call).and_call_original
            post :token, {:grant_type => "authorization_code", :code => authorization_code.code, :redirect_uri => authorization_code.redirect_uri}
          end

          xit "sets the current user on the access token" do
            expect(Roper::GenerateAccessToken).to receive(:call).with(hash_including(:principal => "abc123")).and_call_original
            post :token, {:grant_type => "authorization_code", :code => authorization_code.code, :redirect_uri => authorization_code.redirect_uri}
          end

          it "redeems the authorization code" do
            expect(Roper::RedeemAuthorizationCode).to receive(:call).and_call_original
            post :token, {:grant_type => "authorization_code", :code => authorization_code.code, :redirect_uri => authorization_code.redirect_uri}
          end
        end

        context "RedeemAuthorizationCode fails" do
          let(:authorization_code) { FactoryGirl.create(:active_record_authorization_code, :client => client) }

          before :each do
            failed_result = double("fail")
            expect(failed_result).to receive(:success?).and_return(false)
            Roper::RedeemAuthorizationCode.stub(:call).and_return(failed_result)
            post :token, {:grant_type => "authorization_code", :code => authorization_code.code}
          end

          it "returns a 400 status code" do
            expect(response.code).to eq("400")
          end

          it "returns an error response" do
            expect(response.body).to eq("{\"error\":\"invalid_grant\"}")
          end
        end
      end

      context "grant_type=refresh_token" do
        context "ValidateRefreshToken fails" do
          before :each do
            failed_result = double("fail")
            expect(failed_result).to receive(:success?).and_return(false)
            Roper::ValidateRefreshToken.stub(:call).and_return(failed_result)
            post :token, {:grant_type => "refresh_token", :refresh_token => "foo"}
          end

          it "returns a 400 status code" do
            expect(response.code).to eq("400")
          end

          it "returns an invalid_grant error response" do
            expect(response.body).to eq("{\"error\":\"invalid_grant\"}")
          end
        end

        context "ValidateRefreshToken succeeds" do
          let(:refresh_token) { FactoryGirl.create(:active_record_refresh_token, :client => client) }

          it "returns a 200 status code" do
            post :token, {:grant_type => "refresh_token", :refresh_token => refresh_token.token}
            expect(response.code).to eq("200")
          end

          it "returns an access token response" do
            post :token, {:grant_type => "refresh_token", :refresh_token => refresh_token.token}
            expect(response.body).to match(/{"access_token":"[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}","token_type":"Bearer","expires_in":900}/)
          end

          it "generates an access token" do
            expect(Roper::GenerateAccessToken).to receive(:call).and_call_original
            post :token, {:grant_type => "refresh_token", :refresh_token => refresh_token.token}
          end

          xit "sets the current user on the access token" do
            expect(Roper::GenerateAccessToken).to receive(:call).with(hash_including(:principal => "abc123")).and_call_original
            post :token, {:grant_type => "refresh_token", :refresh_token => refresh_token.token}
          end
        end
      end

      context "grant_type=password" do
        context "username parameter is missing" do
          before :each do
            post :token, {:grant_type => "password"}
          end

          it "returns a 400 status code" do
            expect(response.code).to eq("400")
          end

          it "returns an invalid_request error response" do
            expect(response.body).to eq("{\"error\":\"invalid_request\",\"error_description\":\"username is required\"}")
          end
        end

        context "password parameter is missing" do
          before :each do
            post :token, {:grant_type => "password", :username => "foo"}
          end

          it "returns a 400 status code" do
            expect(response.code).to eq("400")
          end

          it "returns an invalid_request error response" do
            expect(response.body).to eq("{\"error\":\"invalid_request\",\"error_description\":\"password is required\"}")
          end
        end

        it "calls the configured authenticate_resource_owner_method" do
          expect(controller).to receive(Roper.authenticate_resource_owner_method).with("foo", "bar").and_return(true)
          post :token, {:grant_type => "password", :username => "foo", :password => "bar"}
        end

        context "authenticate_resource_owner_method returns true" do
          before :each do
            expect(controller).to receive(Roper.authenticate_resource_owner_method).with("foo", "bar").and_return(true)
          end

          it "generates an access token" do
            expect(Roper::GenerateAccessToken).to receive(:call).and_call_original
            post :token, {:grant_type => "password", :username => "foo", :password => "bar"}
          end

          context "access token generation successful" do
            before :each do
              expect(Roper::GenerateAccessToken).to receive(:call).and_call_original
              post :token, {:grant_type => "password", :username => "foo", :password => "bar"}
            end

            it "returns a 200 status code" do
              expect(response.code).to eq("200")
            end

            it "returns an access token" do
              expect(response.body).to match(/{"access_token":"[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}","token_type":"Bearer","expires_in":900}/)
            end
          end

          context "access token generation fails" do
            before :each do
              failed_response = double("fail")
              expect(failed_response).to receive(:success?).and_return(false)
              expect(Roper::GenerateAccessToken).to receive(:call).and_return(failed_response)
              post :token, {:grant_type => "password", :username => "foo", :password => "bar"}
            end

            it "returns a 500 status code" do
              expect(response.code).to eq("500")
            end

            it "returns an error response" do
              expect(response.body).to eq("{\"error\":\"server_error\"}")
            end
          end
        end

        context "authenticate_resource_owner_method returns false" do
          before :each do
            expect(controller).to receive(Roper.authenticate_resource_owner_method).with("foo", "bar").and_return(false)
            post :token, {:grant_type => "password", :username => "foo", :password => "bar"}
          end

          it "returns a 400 status code" do
            expect(response.code).to eq("400")
          end

          it "returns an invalid_grant error response" do
            expect(response.body).to eq("{\"error\":\"invalid_grant\"}")
          end
        end
      end

      context "grant_type=client_credentials" do
        it "generates an access token" do
          expect(Roper::GenerateAccessToken).to receive(:call).and_call_original
          post :token, {:grant_type => "client_credentials"}
        end

        context "access token generation successful" do
          before :each do
            expect(Roper::GenerateAccessToken).to receive(:call).and_call_original
            post :token, {:grant_type => "client_credentials"}
          end

          it "returns a 200 status code" do
            expect(response.code).to eq("200")
          end

          it "returns an access token" do
            expect(response.body).to match(/{"access_token":"[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}","token_type":"Bearer","expires_in":900}/)
          end
        end

        context "access token generation fails" do
          before :each do
            failed_response = double("fail")
            expect(failed_response).to receive(:success?).and_return(false)
            expect(Roper::GenerateAccessToken).to receive(:call).and_return(failed_response)
            post :token, {:grant_type => "client_credentials"}
          end

          it "returns a 500 status code" do
            expect(response.code).to eq("500")
          end

          it "returns an error response" do
            expect(response.body).to eq("{\"error\":\"server_error\"}")
          end
        end
      end

      context "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer" do
        let(:jwt_issuer) { FactoryGirl.create(:active_record_jwt_issuer, :client => client) }
        let(:jwt_issuer_key) { FactoryGirl.build(:active_record_jwt_issuer_key, :hmac_secret => hmac_secret) }
        let(:claims) { {"iss" => jwt_issuer.issuer, "sub" => "abc123", "aud" => "https://api.mycompany.com"} }
        let(:hmac_secret) { "shhhh!" }
        let(:hmac_assertion) { JWT.encode claims, hmac_secret, 'HS256'}

        before :each do
          jwt_issuer.jwt_issuer_keys << jwt_issuer_key
          jwt_issuer.save
        end

        context "assertion parameter is missing" do
          before :each do
            post :token, {:grant_type => "urn:ietf:params:oauth:grant-type:jwt-bearer"}
          end

          it "returns a 400 status code" do
            expect(response.code).to eq("400")
          end

          it "returns an invalid_request error response" do
            expect(response.body).to eq("{\"error\":\"invalid_request\",\"error_description\":\"assertion is required\"}")
          end
        end

        context "assertion parameter is not a JWT" do
          before :each do
            post :token, {:grant_type => "urn:ietf:params:oauth:grant-type:jwt-bearer", :assertion => "foo"}
          end

          it "returns a 400 status code" do
            expect(response.code).to eq("400")
          end

          it "returns an invalid_request error response" do
            expect(response.body).to eq("{\"error\":\"invalid_request\",\"error_description\":\"invalid JWT assertion\"}")
          end
        end

        context "client does not have any JWT issuers configured" do
          before :each do
            client.jwt_issuers.clear
            client.save
            post :token, {:grant_type => "urn:ietf:params:oauth:grant-type:jwt-bearer", :assertion => hmac_assertion}
          end

          it "returns a 400 status code" do
            expect(response.code).to eq("400")
          end

          it "returns an invalid_request error response" do
            expect(response.body).to eq("{\"error\":\"invalid_grant\"}")
          end
        end

        context "client does not have any JWT issuer keys configured" do
          before :each do
            client.jwt_issuers.each {|jwt_issuer| jwt_issuer.jwt_issuer_keys.clear}
            client.save
            post :token, {:grant_type => "urn:ietf:params:oauth:grant-type:jwt-bearer", :assertion => hmac_assertion}
          end

          it "returns a 400 status code" do
            expect(response.code).to eq("400")
          end

          it "returns an invalid_request error response" do
            expect(response.body).to eq("{\"error\":\"invalid_grant\"}")
          end
        end

        context "assertion contains an unsupported algorithm for the client" do
          let(:hmac_assertion) { JWT.encode claims, hmac_secret, 'HS512'}

          before :each do
            post :token, {:grant_type => "urn:ietf:params:oauth:grant-type:jwt-bearer", :assertion => hmac_assertion}
          end

          it "returns a 400 status code" do
            expect(response.code).to eq("400")
          end

          it "returns an invalid_request error response" do
            expect(response.body).to eq("{\"error\":\"invalid_grant\"}")
          end
        end

        context "assertion contains an unknown issuer" do
          let(:claims) { {"iss" => "foo", "sub" => "abc123", "aud" => "https://api.mycompany.com"} }

          before :each do
            post :token, {:grant_type => "urn:ietf:params:oauth:grant-type:jwt-bearer", :assertion => hmac_assertion}
          end

          it "returns a 400 status code" do
            expect(response.code).to eq("400")
          end

          it "returns an invalid_request error response" do
            expect(response.body).to eq("{\"error\":\"invalid_grant\"}")
          end
        end

        context "valid HMAC signed assertion" do
          context "access token generation succeeds" do
            before :each do
              post :token, {:grant_type => "urn:ietf:params:oauth:grant-type:jwt-bearer", :assertion => hmac_assertion}
            end

            it "returns a 200 status code" do
              expect(response.code).to eq("200")
            end

            it "returns an access token" do
              expect(response.body).to match(/{"access_token":"[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}","token_type":"Bearer","expires_in":900}/)
            end
          end

          context "access token generation fails" do
            before :each do
              failed_response = double("fail")
              expect(failed_response).to receive(:success?).and_return(false)
              expect(Roper::GenerateAccessToken).to receive(:call).and_return(failed_response)
              post :token, {:grant_type => "urn:ietf:params:oauth:grant-type:jwt-bearer", :assertion => hmac_assertion}
            end

            it "returns a 500 status code" do
              expect(response.code).to eq("500")
            end

            it "returns an error response" do
              expect(response.body).to eq("{\"error\":\"server_error\"}")
            end
          end
        end

        context "valid RSA signed assertion" do
          let(:rsa_private_key) { OpenSSL::PKey::RSA.generate 2048 }
          let(:rsa_public_key) { rsa_private_key.public_key }
          let(:claims) { {"iss" => jwt_issuer.issuer, "sub" => "abc123", "aud" => "https://api.mycompany.com"} }
          let(:rsa_assertion) { JWT.encode claims, rsa_private_key, 'RS256'}

          before :each do
            jwt_issuer.jwt_issuer_keys.clear
            jwt_issuer.jwt_issuer_keys.build(:public_key => rsa_public_key, :algorithm => "RS256")
            jwt_issuer.save!
          end

          context "access token generation succeeds" do
            before :each do
              post :token, {:grant_type => "urn:ietf:params:oauth:grant-type:jwt-bearer", :assertion => rsa_assertion}
            end

            it "returns a 200 status code" do
              expect(response.code).to eq("200")
            end

            it "returns an access token" do
              expect(response.body).to match(/{"access_token":"[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}","token_type":"Bearer","expires_in":900}/)
            end
          end

          context "access token generation fails" do
            before :each do
              failed_response = double("fail")
              expect(failed_response).to receive(:success?).and_return(false)
              expect(Roper::GenerateAccessToken).to receive(:call).and_return(failed_response)
              post :token, {:grant_type => "urn:ietf:params:oauth:grant-type:jwt-bearer", :assertion => rsa_assertion}
            end

            it "returns a 500 status code" do
              expect(response.code).to eq("500")
            end

            it "returns an error response" do
              expect(response.body).to eq("{\"error\":\"server_error\"}")
            end
          end
        end

        context "valid ECDSA signed assertion" do
          let(:ecdsa_private_key) do
            ecdsa_key = OpenSSL::PKey::EC.new 'prime256v1'
            ecdsa_key.generate_key
            ecdsa_key
          end
          let(:ecdsa_public_key) do
            ecdsa_public_key = OpenSSL::PKey::EC.new ecdsa_private_key
            ecdsa_public_key.private_key = nil
            ecdsa_public_key
          end
          let(:claims) { {"iss" => jwt_issuer.issuer, "sub" => "abc123", "aud" => "https://api.mycompany.com"} }
          let(:ecdsa_assertion) { JWT.encode claims, ecdsa_private_key, 'ES256'}

          before :each do
            jwt_issuer.jwt_issuer_keys.clear
            jwt_issuer.jwt_issuer_keys.build(:public_key => ecdsa_public_key, :algorithm => "ES256")
            jwt_issuer.save!
          end

          context "access token generation succeeds" do
            before :each do
              post :token, {:grant_type => "urn:ietf:params:oauth:grant-type:jwt-bearer", :assertion => ecdsa_assertion}
            end

            it "returns a 200 status code" do
              expect(response.code).to eq("200")
            end

            it "returns an access token" do
              expect(response.body).to match(/{"access_token":"[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}","token_type":"Bearer","expires_in":900}/)
            end
          end

          context "access token generation fails" do
            before :each do
              failed_response = double("fail")
              expect(failed_response).to receive(:success?).and_return(false)
              expect(Roper::GenerateAccessToken).to receive(:call).and_return(failed_response)
              post :token, {:grant_type => "urn:ietf:params:oauth:grant-type:jwt-bearer", :assertion => ecdsa_assertion}
            end

            it "returns a 500 status code" do
              expect(response.code).to eq("500")
            end

            it "returns an error response" do
              expect(response.body).to eq("{\"error\":\"server_error\"}")
            end
          end
        end
      end
    end
  end
end
