require "spec_helper"

module Roper
  describe AuthorizationController do
    describe "routing" do
      routes { Roper::Engine.routes }

      it "routes to #authorize" do
        get("/authorize").should route_to("roper/authorization#authorize")
      end

      it "routes to #approve_authorization" do
        post("/approve_authorization").should route_to("roper/authorization#approve_authorization")
      end

      it "routes to #deny_authorization" do
        post("/deny_authorization").should route_to("roper/authorization#deny_authorization")
      end
    end
  end
end
