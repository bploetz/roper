require "spec_helper"

describe Roper::Repository do
  before :each do
    Roper::Repository.repositories.clear
  end

  let(:repo1) { Object.new }
  let(:repo2) { Object.new }

  it "registers repositories under a key" do
    Roper::Repository.register(:repo1, repo1)
    expect(Roper::Repository.for(:repo1)).to eq(repo1)
  end
end
