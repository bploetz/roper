require 'spec_helper'

module Roper
  describe ApplicationHelper do
    describe "create_error" do
      it "serializes error" do
        expect(create_error("foo")).to eq({:error => "foo"})
      end

      it "serializes error_description if given" do
        expect(create_error("foo", "bar")).to eq({:error => "foo", :error_description => "bar"})
      end

      it "serializes error_uri if given" do
        expect(create_error("foo", "bar", "baz")).to eq({:error => "foo", :error_description => "bar", :error_uri => "baz"})
      end
    end
  end
end
