require 'spec_helper'

module Roper
  describe GenerateAuthorizationCode do
    let(:client) { FactoryGirl.create(:active_record_client) }
    let(:request_redirect_uri) { nil }
    let(:context) { GenerateAuthorizationCode.call(client: client, request_redirect_uri: request_redirect_uri) }

    context "#call" do
      context "when creating the authorization code succeeds" do
        it "succeeds" do
          expect(context.success?).to eq(true)
        end

        it "creates an authorization code" do
          context
          authorization_code = Roper::Repository.for(:authorization_code).model_class.first
          expect(authorization_code).not_to eq(nil)
          expect(authorization_code.client_id).to eq(client.id)
          expect(authorization_code.code).to match(/[a-f0-9]{12}/)
          expect(authorization_code.redirect_uri).to eq(nil)
          expect(authorization_code.expires_at).not_to eq(nil)
        end

        context "when the request has a redirect uri" do
          let(:request_redirect_uri) { "http://www.foo.com" }

          it "creates an authorization code with a redirect_uri" do
            context
            authorization_code = Roper::Repository.for(:authorization_code).model_class.first
            expect(authorization_code).not_to eq(nil)
            expect(authorization_code.redirect_uri).to eq("http://www.foo.com")
          end
        end
      end

      context "when creating the authorization code fails" do
        let(:stub_authorization_code) { double("authorization code") }

        before :each do
          expect(stub_authorization_code).to receive(:save).and_return(false)
          expect(Roper::Repository.for(:authorization_code)).to receive(:new).and_return(stub_authorization_code)
        end

        it "fails" do
          expect(context.success?).to eq(false)
        end
      end
    end
  end
end
