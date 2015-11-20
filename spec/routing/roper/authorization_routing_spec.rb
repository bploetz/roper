require "spec_helper"

module Roper
  describe AuthorizationController do
    describe "routing" do
      routes { Roper::Engine.routes }

      it "routes to #authorize" do
        get("/authorize").should route_to("roper/authorization#authorize")
      end
    end
  end
end
