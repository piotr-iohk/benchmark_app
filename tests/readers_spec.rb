require_relative '../helpers/readers'

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

  it "read_to_hash" do
    res = File.read("#{Dir.pwd}/tests/artifacts/restoration.txt")
    h = Restorations.read_to_hash res
    expect(h).to eq({'restore mainnet seq' => 1064.5,
                     'restore mainnet 1% ownership' => 3566,
                     'restore mainnet 2% ownership' => 6493.12})
  end
end

describe Helpers::Readers::Latencies do
  it "read_to_hash" do
    res = File.read("#{Dir.pwd}/tests/artifacts/latency.log")
    h = Latencies.read_to_hash res
    v1 = h['Random wallets']['Latencies for 10 fixture wallets scenario']['getUTxOsStatistics']
    expect(v1).to eq 1.2

    v2 = h['Icarus wallets']['Latencies for 100 fixture wallets scenario']['listWallets']
    expect(v2).to eq 575.5

    v3 = h['Icarus wallets']['Latencies for 100 fixture wallets scenario']['getNetworkInfo']
    expect(v3).to eq 10.0

    v4 = h['+++ Run benchmark - jormungandr']['Latencies for 2 fixture wallets scenario']['listTransactions']
    expect(v4).to eq 2.9

    v5 = h['Random wallets']['Latencies for 2 fixture wallets with 100 utxos scenario']['postTransactionFee']
    expect(v5).to eq 11.2

    v6 = h['Icarus wallets']['Latencies for 2 fixture wallets with 1000 utxos scenario']['getNetworkInfo']
    expect(v6).to eq 0.4

    v7 = h['Icarus wallets']['Latencies for 2 fixture wallets with 100 utxos scenario']['listAddresses']
    expect(v7).to eq 13.4

    v8 = h['Icarus wallets']['Latencies for 10 fixture wallets with 10 txs scenario']['listWallets']
    expect(v8).to eq 23.5
  end
end
