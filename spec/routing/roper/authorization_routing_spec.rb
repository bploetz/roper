require "spec_helper"

module Roper
  describe AuthorizationController do
    describe "routing" do
      it "routes to #token" do
        post("/token").should route_to("authorization#create")
      end
    end
  end
end
