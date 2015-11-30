require 'spec_helper'

module Roper
  describe AuthorizationController do
    routes { Roper::Engine.routes }

    let(:client) { FactoryGirl.create(:active_record_client) }
    let(:client_with_redirect) do
      client = FactoryGirl.create(:active_record_client, :client_id => 'client_with_redirect')
      client.client_redirect_uris.create(:uri => "http://www.foo.com")
      client
    end
    let(:client_with_many_redirects) do
      client = FactoryGirl.create(:active_record_client, :client_id => 'client_with_many_redirects')
      client.client_redirect_uris.create(:uri => "http://www.foo.com")
      client.client_redirect_uris.create(:uri => "http://www.bar.com")
      client.client_redirect_uris.create(:uri => "http://www.baz.com")
      client
    end


    context "filters" do
      describe "#validate_logged_in" do
        it "calls the configured signed_in_+method" do
          expect(controller).to receive(Roper.signed_in_method)
          get :authorize, {:client_id => client.client_id}
        end
      end

      describe "#validate_parameters" do
        before :each do
          controller.stub(:validate_logged_in).and_return(true)
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

        context "client has one configured redirect_uri" do
          context "redirect_uri parameter is present" do
            it "allows the request if redirect_uri param matches configured redirect_uri" do
              get :authorize, {:response_type => "code", :client_id => client_with_redirect.client_id, :redirect_uri => client_with_redirect.client_redirect_uris[0].uri}
              expect(response.code).to eq("200")
            end

            context "redirect_uri param does not match the configured redirect_uri" do
              it "returns an invalid_request error response" do
                get :authorize, {:response_type => "code", :client_id => client_with_redirect.client_id, :redirect_uri => "http://www.google.com"}
                expect(response.body).to eq("{\"error\":\"invalid_request\",\"error_description\":\"invalid redirect_uri\"}")
              end

              it "includes state in the error if sent in the request" do
                get :authorize, {:response_type => "code", :client_id => client_with_redirect.client_id, :redirect_uri => "http://www.google.com", :state => "foo"}
                expect(response.body).to eq("{\"error\":\"invalid_request\",\"error_description\":\"invalid redirect_uri\",\"state\":\"foo\"}")
              end
            end
          end

          context "redirect_uri parameter is not present" do
            it "allows the request" do
              get :authorize, {:response_type => "code", :client_id => client_with_redirect.client_id}
              expect(response.code).to eq("200")
            end
          end
        end

        context "client has many configured redirect_uris" do
          context "redirect_uri parameter is present" do
            context "redirect_uri matches a configured redirect uri" do
              it "allows the request" do
                [0,1,2].each do |i|
                  get :authorize, {:response_type => "code", :client_id => client_with_many_redirects.client_id, :redirect_uri => client_with_many_redirects.client_redirect_uris[i].uri}
                  expect(response.code).to eq("200")
                end
              end
            end

            context "redirect_uri does not match a configured redirect uri" do
              it "returns an invalid_request error response" do
                get :authorize, {:response_type => "code", :client_id => client_with_many_redirects.client_id, :redirect_uri => "http://www.google.com"}
                expect(response.body).to eq("{\"error\":\"invalid_request\",\"error_description\":\"invalid redirect_uri\"}")
              end

              it "includes state in the error if sent in the request" do
                get :authorize, {:response_type => "code", :client_id => client_with_many_redirects.client_id, :redirect_uri => "http://www.google.com", :state => "foo"}
                expect(response.body).to eq("{\"error\":\"invalid_request\",\"error_description\":\"invalid redirect_uri\",\"state\":\"foo\"}")
              end
            end
          end

          context "redirect_uri parameter is not present" do
            it "returns an invalid_request error response" do
              get :authorize, {:response_type => "code", :client_id => client_with_many_redirects.client_id}
              expect(response.body).to eq("{\"error\":\"invalid_request\",\"error_description\":\"redirect_uri is required\"}")
            end
          end
        end

        context "client does not have a configured redirect_uri" do
          it "returns an invalid_request error response" do
            get :authorize, {:response_type => "code", :client_id => client.client_id}
            expect(response.body).to eq("{\"error\":\"invalid_request\",\"error_description\":\"invalid redirect_uri\"}")
          end

          it "includes state in the error if sent in the request" do
            get :authorize, {:response_type => "code", :client_id => client.client_id, :state => "foo"}
            expect(response.body).to eq("{\"error\":\"invalid_request\",\"error_description\":\"invalid redirect_uri\",\"state\":\"foo\"}")
          end
        end
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
          get :authorize, {:client_id => client_with_redirect.client_id}
          expect(response.body).to eq("{\"error\":\"invalid_request\",\"error_description\":\"response_type is required\"}")
        end

        it "includes state in the error if sent in the request" do
          get :authorize, {:client_id => client_with_redirect.client_id, :state => "foo"}
          expect(response.body).to eq("{\"error\":\"invalid_request\",\"error_description\":\"response_type is required\",\"state\":\"foo\"}")
        end
      end

      context "response_type parameter is unsupported" do
        it "returns a 400 status code" do
          get :authorize, {:response_type => "foo", :client_id => client.client_id, :redirect_uri => "http://www.foo.com"}
          expect(response.code).to eq("400")
        end

        it "returns an unsupported_response_type error response" do
          get :authorize, {:response_type => "foo", :client_id => client_with_redirect.client_id}
          expect(response.body).to eq("{\"error\":\"unsupported_response_type\"}")
        end

        it "includes state in the error if sent in the request" do
          get :authorize, {:response_type => "foo", :client_id => client_with_redirect.client_id, :state => "foo"}
          expect(response.body).to eq("{\"error\":\"unsupported_response_type\",\"state\":\"foo\"}")
        end
      end

      context "authorization code grant" do
        before :each do
          get :authorize, {:response_type => "code", :client_id => client_with_redirect.client_id, :scope => "read write", :state => "abc123"}
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

    describe "POST /oauth/approve_authorization" do
      before :each do
        controller.stub(:validate_logged_in).and_return(true)
      end

      it "returns a 302 status code" do
        post :approve_authorization, {:client_id => client_with_redirect.client_id}
        expect(response.code).to eq("302")
      end

      it "redirects to redirect_url" do
        Roper::ActiveRecord::AuthorizationCode.any_instance.stub(:code).and_return("abc123")
        post :approve_authorization, {:client_id => client_with_redirect.client_id, :redirect_uri => client_with_redirect.client_redirect_uris[0].uri}
        expect(response).to redirect_to("http://www.foo.com?code=abc123")
      end

      it "includes state if present in original request" do
        Roper::ActiveRecord::AuthorizationCode.any_instance.stub(:code).and_return("abc123")
        post :approve_authorization, {:client_id => client_with_redirect.client_id, :redirect_uri => client_with_redirect.client_redirect_uris[0].uri, :state => "foo"}
        expect(response).to redirect_to("http://www.foo.com?code=abc123&state=foo")
      end
    end
  end
end
