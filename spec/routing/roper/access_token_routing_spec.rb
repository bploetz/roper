require "spec_helper"

module Roper
  describe AuthorizationController do
    describe "routing" do
      routes { Roper::Engine.routes }

      it "routes to #token" do
        post("/token").should route_to("roper/access_token#token")
      end
    end
  end
end
