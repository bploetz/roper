require 'spec_helper'

module Roper
  describe AuthorizationController do
    routes { Roper::Engine.routes }

    let(:client) { FactoryGirl.create(:active_record_client) }

    describe "check_logged_in filter" do
      it "calls the configured signed_in_+method" do
        expect(controller).to receive(Roper.signed_in_method)
        get :authorize, {:client_id => client.client_id}
      end
    end

    describe "GET /oauth/authorize" do
      before :each do
        controller.stub(:check_logged_in).and_return(true)
      end

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

      context "authorization code grant" do
        before :each do
          get :authorize, {:response_type => "code", :client_id => client.client_id, :redirect_uri => "http://www.foo.com", :scope => "read write", :state => "abc123"}
        end

        it "returns a 200 status code" do
          expect(response.code).to eq("200")
        end

        it "renders the authorize view" do
          expect(response).to render_template("authorize")
        end

        it "assigns @redirect_uri" do
          expect(assigns(:redirect_uri)).to eq("http://www.foo.com")
        end

        it "assigns @scope" do
          expect(assigns(:scope)).to eq("read write")
        end

        it "assigns @scopes if scope has multiple values" do
          expect(assigns(:scopes)).to eq(["read", "write"])
        end
      end
    end
  end
end
