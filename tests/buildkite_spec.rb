require_relative '../helpers/buildkite'

include Helpers

describe Buildkite do
  describe "restoration_keys" do
    it "mainnet" do
        bk = Buildkite.new
        k1, k2, k3 = bk.restoration_keys 'restore-byron-mainnet.txt'
        expect(k1).to eq 'restore mainnet seq'
        expect(k2).to eq 'restore mainnet 1% ownership'
        expect(k3).to eq 'restore mainnet 2% ownership'
    end

    it "testnet" do
        bk = Buildkite.new
        k1, k2, k3 = bk.restoration_keys 'restore-byron-testnet.txt'
        expect(k1).to eq 'restore testnet (1097911063) seq'
        expect(k2).to eq 'restore testnet (1097911063) 1% ownership'
        expect(k3).to eq 'restore testnet (1097911063) 2% ownership'
    end

    it "wrong artifact name" do
        bk = Buildkite.new
        wrong_artifact = 'wrong.txt'
        expect { bk.restoration_keys wrong_artifact }.to raise_error("Wrong artifact name: #{wrong_artifact}")
    end
  end
end
