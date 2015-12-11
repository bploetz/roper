require 'spec_helper'

module Roper
  describe AccessTokenController do
    routes { Roper::Engine.routes }

    let!(:client) { FactoryGirl.create(:active_record_client, :client_id => "test", :client_secret => "test") }

    describe "authenticate_client filter" do
      context "basic authentication" do
        context "invalid client_id" do
          before :each do
            @request.env["HTTP_AUTHORIZATION"] = "Basic: #{::Base64.strict_encode64("foo:bar")}"
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
            @request.env["HTTP_AUTHORIZATION"] = "Basic: #{::Base64.strict_encode64("test:bar")}"
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
          @request.env["HTTP_AUTHORIZATION"] = "Basic: #{::Base64.strict_encode64("test:test")}"
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
        @request.env["HTTP_AUTHORIZATION"] = "Basic: #{::Base64.strict_encode64("test:test")}"
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
            expect(response.body).to match(/{"access_token":"[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}","token_type":"Bearer"}/)
          end

          it "generates an access code" do
            expect(Roper::GenerateAccessToken).to receive(:call).and_call_original
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
            expect(response.body).to match(/{"access_token":"[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}","token_type":"Bearer"}/)
          end

          it "generates an access code" do
            expect(Roper::GenerateAccessToken).to receive(:call).and_call_original
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

          it "returns a 500 status code" do
            expect(response.code).to eq("500")
          end

          it "returns an unexpected error response" do
            expect(response.body).to eq("{\"message\":\"unexpected error\"}")
          end
        end
      end
    end
  end
end
