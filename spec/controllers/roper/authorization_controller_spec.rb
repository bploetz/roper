require 'spec_helper'

module Roper
  describe AuthorizationController do
    routes { Roper::Engine.routes }

    let(:client) { FactoryGirl.create(:active_record_client) }

    describe "GET /oauth/authorize" do
      context "response_type parameter is missing" do
        before :each do
          get :authorize, {:client_id => client.client_id}
        end

        it "returns a 400 status code" do
          expect(response.code).to eq("400")
        end

        it "returns an invalid_request error response" do
          expect(response.body).to eq("{\"error\":\"invalid_request\"}")
        end
      end

      context "client_id parameter is missing" do
        before :each do
          get :authorize, {:response_type => "code"}
        end

        it "returns a 400 status code" do
          expect(response.code).to eq("400")
        end

        it "returns an invalid_request error response" do
          expect(response.body).to eq("{\"error\":\"invalid_request\"}")
        end
      end

      context "response_type parameter is unsupported" do
        before :each do
          get :authorize, {:response_type => "foo", :client_id => client.client_id}
        end

        it "returns a 400 status code" do
          expect(response.code).to eq("400")
        end

        it "returns an unsupported_response_type error response" do
          expect(response.body).to eq("{\"error\":\"unsupported_response_type\"}")
        end
      end
    end
  end
end
