require 'spec_helper'

module Roper
  describe AccessTokenController do
    routes { Roper::Engine.routes }

    let(:client) { FactoryGirl.create(:active_record_client) }

    describe "authenticate_client filter" do
      it "returns a 401 for missing basic auth credentials" do
        post :token, {}
        expect(response.code).to eq("401")
      end

      it "returns a 401 for invalid basic auth credentials" do
        @request.env["HTTP_AUTHORIZATION"] = "Basic: #{::Base64.strict_encode64("foo:bar")}"
        post :token, {}
        expect(response.code).to eq("401")
      end

      it "returns a 401 if client_secret doesn't match" do
        @request.env["HTTP_AUTHORIZATION"] = "Basic: #{::Base64.strict_encode64(client.client_id + ":bar")}"
        post :token, {}
        expect(response.code).to eq("401")
      end

      it "allows clients with valid basic auth credentials" do
        @request.env["HTTP_AUTHORIZATION"] = "Basic: #{::Base64.strict_encode64(client.client_id + ":" + client.client_secret)}"
        post :token, {}
        expect(response.code).to eq("400")
      end
    end

    describe "POST /oauth/token" do
      before :each do
        subject.stub(:authenticate_client)
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
    end
  end
end
