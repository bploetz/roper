require 'spec_helper'

module Roper
  describe AuthorizationController do

    describe "POST /token" do
      xit "does something" do
        expect {
          post :token, {}, valid_session
        }.to eq(200)
      end
    end
  end
end
