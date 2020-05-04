require_relative 'spec_helper'

include Helpers::Readers

describe Helpers::Readers::Restorations do
  describe "restoration_keys" do
    it "mainnet" do
      k1, k2, k3 = Restorations.restoration_keys 'restore-byron-mainnet.txt'
      expect(k1).to eq 'restore mainnet seq'
      expect(k2).to eq 'restore mainnet 1% ownership'
      expect(k3).to eq 'restore mainnet 2% ownership'
    end

    it "testnet" do
      k1, k2, k3 = Restorations.restoration_keys 'restore-byron-testnet.txt'
      expect(k1).to eq 'restore testnet (1097911063) seq'
      expect(k2).to eq 'restore testnet (1097911063) 1% ownership'
      expect(k3).to eq 'restore testnet (1097911063) 2% ownership'
    end

    it "wrong artifact name" do
      wrong_artifact = 'wrong.txt'
      expect { Restorations.restoration_keys wrong_artifact }.to raise_error("Wrong artifact name: #{wrong_artifact}")
    end
  end

  it "read_to_hash - mainnet" do
    res = File.read("#{Dir.pwd}/tests/artifacts/restoration-mainnet.txt")
    h = Restorations.read_to_hash res, "mainnet"
    expect(h).to eq({time_seq: 1064.5,
                     time_1per: 3566,
                     time_2per: 6493.12})
  end

  it "read_to_hash - testnet" do
    res = File.read("#{Dir.pwd}/tests/artifacts/restoration-testnet.txt")
    h = Restorations.read_to_hash res, "testnet"
    expect(h).to eq({time_seq: 225,
                     time_1per: 250,
                     time_2per: 255.7})
  end
end

describe Helpers::Readers::Latencies do
  it "read_to_hash" do
    res = File.read("#{Dir.pwd}/tests/artifacts/latency.log")
    h = Latencies.read_to_hash res

    v = h['Random wallets']['Non-cached run']['getNetworkInfo']
    expect(v).to eq 1.4

    v = h['Icarus wallets']['Non-cached run']['getNetworkInfo']
    expect(v).to eq 1.3

    v = h['+++ Run benchmark - jormungandr']['Non-cached run']['getNetworkInfo']
    expect(v).to eq 1.1

    v = h['Random wallets']['Latencies for 10 fixture wallets scenario']['getUTxOsStatistics']
    expect(v).to eq 0.7

    v = h['Icarus wallets']['Latencies for 100 fixture wallets scenario']['listWallets']
    expect(v).to eq 216.2

    v = h['Icarus wallets']['Latencies for 100 fixture wallets scenario']['getNetworkInfo']
    expect(v).to eq 0.1

    v = h['+++ Run benchmark - jormungandr']['Latencies for 2 fixture wallets scenario']['listTransactions']
    expect(v).to eq 1.7

    v = h['Random wallets']['Latencies for 2 fixture wallets with 100 utxos scenario']['postTransactionFee']
    expect(v).to eq 5.7

    v = h['Icarus wallets']['Latencies for 2 fixture wallets with 1000 utxos scenario']['getNetworkInfo']
    expect(v).to eq 0.0

    v = h['Icarus wallets']['Latencies for 2 fixture wallets with 100 utxos scenario']['listAddresses']
    expect(v).to eq 7.4

    v = h['Icarus wallets']['Latencies for 10 fixture wallets with 10 txs scenario']['listWallets']
    expect(v).to eq 12.5
  end

  it "read_to_hash empty" do
    h = Latencies.read_to_hash ""
    expect(h).to be_empty
  end

  it "read_to_hash wrong format" do
    res = File.read("#{Dir.pwd}/tests/artifacts/restoration-mainnet.txt")
    h = Latencies.read_to_hash res
    expect(h).to be_empty
  end

  it "read_to_hash wrong format 2" do
    res = File.read("#{Dir.pwd}/tests/artifacts/latency-bad.log")
    h = Latencies.read_to_hash res

    v = h['+++ Run benchmark - jormungandr']['Latencies for 2 fixture wallets scenario']['listTransactions']
    expect(v).to eq 2.5

    v = h['+++ Run benchmark - jormungandr']['error, called at test/bench/Latency.hs:434:27 in main:Main']
    expect(v).to eq nil

  end

end
