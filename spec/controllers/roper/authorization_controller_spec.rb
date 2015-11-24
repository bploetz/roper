require 'spec_helper'

module Roper
  describe AuthorizationController do
    routes { Roper::Engine.routes }

    let(:client) { FactoryGirl.create(:active_record_client) }
    let(:client_with_redirect) { FactoryGirl.create(:active_record_client, :client_id => "with_redirect", :redirect_uri => 'http://www.bar.com') }

    describe "check_logged_in filter" do
      it "calls the configured signed_in_+method" do
        expect(controller).to receive(Roper.signed_in_method)
        get :authorize, {:client_id => client.client_id}
      end
    end

    describe "GET /oauth/authorize" do
      before :each do
        controller.stub(:validate_logged_in).and_return(true)
      end

      context "response_type parameter is missing" do
        it "returns a 400 status code" do
          get :authorize, {:client_id => client.client_id, :redirect_uri => "http://www.foo.com"}
          expect(response.code).to eq("400")
        end

        it "returns an invalid_request error response" do
          get :authorize, {:client_id => client.client_id, :redirect_uri => "http://www.foo.com"}
          expect(response.body).to eq("{\"error\":\"invalid_request\",\"error_description\":\"response_type is required\"}")
        end

        it "includes state in the error if sent in the request" do
          get :authorize, {:client_id => client.client_id, :redirect_uri => "http://www.foo.com", :state => "foo"}
          expect(response.body).to eq("{\"error\":\"invalid_request\",\"error_description\":\"response_type is required\",\"state\":\"foo\"}")
        end
      end

      context "client_id parameter is missing" do
        it "returns a 400 status code" do
          get :authorize, {:response_type => "code", :redirect_uri => "http://www.foo.com"}
          expect(response.code).to eq("400")
        end

        it "returns an invalid_request error response" do
          get :authorize, {:response_type => "code", :redirect_uri => "http://www.foo.com"}
          expect(response.body).to eq("{\"error\":\"invalid_request\",\"error_description\":\"client_id is required\"}")
        end

        it "includes state in the error if sent in the request" do
          get :authorize, {:response_type => "code", :redirect_uri => "http://www.foo.com", :state => "foo"}
          expect(response.body).to eq("{\"error\":\"invalid_request\",\"error_description\":\"client_id is required\",\"state\":\"foo\"}")
        end
      end

      context "client has a configured redirect_uri" do
        it "does not return a 400 status code" do
          get :authorize, {:response_type => "code", :client_id => client_with_redirect.client_id}
          expect(response.code).to eq("200")
        end
      end

      context "client does not have a configured redirect_uri" do
        context "redirect_uri parameter is missing" do
          it "returns a 400 status code" do
            get :authorize, {:response_type => "code", :client_id => client.client_id}
            expect(response.code).to eq("400")
          end

          it "returns an invalid_request error response" do
            get :authorize, {:response_type => "code", :client_id => client.client_id}
            expect(response.body).to eq("{\"error\":\"invalid_request\",\"error_description\":\"redirect_uri is required\"}")
          end

          it "includes state in the error if sent in the request" do
            get :authorize, {:response_type => "code", :client_id => client.client_id, :state => "foo"}
            expect(response.body).to eq("{\"error\":\"invalid_request\",\"error_description\":\"redirect_uri is required\",\"state\":\"foo\"}")
          end
        end
      end

      context "response_type parameter is unsupported" do
        it "returns a 400 status code" do
          get :authorize, {:response_type => "foo", :client_id => client.client_id, :redirect_uri => "http://www.foo.com"}
          expect(response.code).to eq("400")
        end

        it "returns an unsupported_response_type error response" do
          get :authorize, {:response_type => "foo", :client_id => client.client_id, :redirect_uri => "http://www.foo.com"}
          expect(response.body).to eq("{\"error\":\"unsupported_response_type\"}")
        end

        it "includes state in the error if sent in the request" do
          get :authorize, {:response_type => "foo", :client_id => client.client_id, :redirect_uri => "http://www.foo.com", :state => "foo"}
          expect(response.body).to eq("{\"error\":\"unsupported_response_type\",\"state\":\"foo\"}")
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

        context "client has a configured redirect_uri" do
          it "assigns @redirect_uri to configured redirect_uri" do
            get :authorize, {:response_type => "code", :client_id => client_with_redirect.client_id, :scope => "read write", :state => "abc123"}
            expect(assigns(:redirect_uri)).to eq("http://www.bar.com")
          end

          it "assigns @redirect_uri to configured redirect_uri and ignores any redirect_uri in the request" do
            get :authorize, {:response_type => "code", :client_id => client_with_redirect.client_id, :redirect_uri => "http://www.foo.com", :scope => "read write", :state => "abc123"}
            expect(assigns(:redirect_uri)).to eq("http://www.bar.com")
          end
        end

        context "client has a configured redirect_uri" do
          it "assigns @redirect_uri to the redirect_uri in the request" do
            expect(assigns(:redirect_uri)).to eq("http://www.foo.com")
          end
        end

        it "assigns @scope" do
          expect(assigns(:scope)).to eq("read write")
        end

        it "assigns @scopes if scope has multiple values" do
          expect(assigns(:scopes)).to eq(["read", "write"])
        end
      end
    end

    describe "POST /oauth/approve_authorization" do
      before :each do
        controller.stub(:validate_logged_in).and_return(true)
      end

      context "client_id parameter is missing" do
        it "returns a 400 status code" do
          post :approve_authorization, {:redirect_uri => "http://www.foo.com"}
          expect(response.code).to eq("400")
        end

        it "returns an invalid_request error response" do
          post :approve_authorization, {:redirect_uri => "http://www.foo.com"}
          expect(response.body).to eq("{\"error\":\"invalid_request\",\"error_description\":\"client_id is required\"}")
        end

        it "includes state in the error if sent in the request" do
          post :approve_authorization, {:redirect_uri => "http://www.foo.com", :state => "foo"}
          expect(response.body).to eq("{\"error\":\"invalid_request\",\"error_description\":\"client_id is required\",\"state\":\"foo\"}")
        end
      end

      context "redirect_uri parameter is missing" do
        it "returns a 400 status code" do
          post :approve_authorization, {:client_id => client.client_id}
          expect(response.code).to eq("400")
        end

        it "returns an invalid_request error response" do
          post :approve_authorization, {:client_id => client.client_id}
          expect(response.body).to eq("{\"error\":\"invalid_request\",\"error_description\":\"redirect_uri is required\"}")
        end

        it "includes state in the error if sent in the request" do
          post :approve_authorization, {:client_id => client.client_id, :state => "foo"}
          expect(response.body).to eq("{\"error\":\"invalid_request\",\"error_description\":\"redirect_uri is required\",\"state\":\"foo\"}")
        end
      end

      it "returns a 302 status code" do
        post :approve_authorization, {:redirect_uri => "http://www.foo.com", :client_id => client.client_id}
        expect(response.code).to eq("302")
      end

      it "redirects to redirect_url" do
        Roper::ActiveRecord::AuthorizationCode.any_instance.stub(:code).and_return("abc123")
        post :approve_authorization, {:redirect_uri => "http://www.foo.com", :client_id => client.client_id}
        expect(response).to redirect_to("http://www.foo.com?code=abc123")
      end

      it "includes state if present in original request" do
        Roper::ActiveRecord::AuthorizationCode.any_instance.stub(:code).and_return("abc123")
        post :approve_authorization, {:redirect_uri => "http://www.foo.com", :client_id => client.client_id, :state => "foo"}
        expect(response).to redirect_to("http://www.foo.com?code=abc123&state=foo")
      end
    end
  end
end
