require 'spec_helper'

module Roper
  describe ValidateAuthorizationCode do
    let(:redirect_uri) { nil }
    let(:client) { FactoryGirl.create(:active_record_client) }
    let(:code) { authorization_code.code}
    let(:context) { ValidateAuthorizationCode.call(client: client, :code => code, :redirect_uri => redirect_uri) }

    context "#call" do
      context "authorization code is not found" do
        let (:code) { nil }

        it "fails" do
          expect(context.success?).to eq(false)
        end
      end

      context "authorization code not associated with client in the request" do
        let(:another_client) { FactoryGirl.create(:active_record_client, :client_id => "hi", :client_secret => "hi") }
        let(:authorization_code) { FactoryGirl.create(:active_record_authorization_code, :client => another_client) }

        it "fails" do
          expect(context.success?).to eq(false)
        end
      end

      context "authorization code already redeemed" do
        let(:authorization_code) { FactoryGirl.create(:active_record_authorization_code, :client => client, :redeemed => true) }

        it "fails" do
          expect(context.success?).to eq(false)
        end
      end

      context "authorization code expired" do
        let(:authorization_code) { FactoryGirl.create(:active_record_authorization_code, :client => client, :expires_at => DateTime.now - 5.minutes) }

        it "fails" do
          expect(context.success?).to eq(false)
        end
      end

      context "authorization code with redirect_uri" do
        let(:authorization_code) { FactoryGirl.create(:active_record_authorization_code, :client => client, :redirect_uri => "http://www.google.com") }

        context "redirect_uri param is missing" do
          it "fails" do
            expect(context.success?).to eq(false)
          end
        end

        context "redirect_uri param does not match authorization code redirect uri" do
          let(:redirect_uri) { "http://www.foo.com" }

          it "fails" do
            expect(context.success?).to eq(false)
          end
        end

        context "redirect_uri param matches authorization code redirect uri" do
          let(:redirect_uri) { "http://www.google.com" }

          it "succeeds" do
            expect(context.success?).to eq(true)
          end
        end
      end
    end
  end
end
