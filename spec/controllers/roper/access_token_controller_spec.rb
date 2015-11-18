require 'spec_helper'

module Roper
  describe AccessTokenController do
    routes { Roper::Engine.routes }

    describe "POST /oauth/token" do
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
