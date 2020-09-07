require_relative 'spec_helper'

include Helpers::Readers

describe Helpers::Readers::Restorations do

  it "read_to_hash - mainnet" do
    res = File.read("#{Dir.pwd}/tests/artifacts/restoration-mainnet.txt")
    h = Restorations.read_to_hash res
    # p h
    expect(h[0]['benchName']).to eq "Seq 0% Wallet"
    expect(h[0]['restorationTime']).to eq 466.7

    expect(h[1]['benchName']).to eq "Rnd 0% Wallet"
    expect(h[1]['listingAddressesTime']).to eq 0.0005687

    expect(h[2]['benchName']).to eq "Rnd 0.1% Wallet"
    expect(h[2]['restorationTime']).to eq 1598

  end

  it "read_to_hash - testnet" do
    res = File.read("#{Dir.pwd}/tests/artifacts/restoration-testnet.txt")
    h = Restorations.read_to_hash res

    expect(h[0]['benchName']).to eq "Seq 0% Wallet"
    expect(h[0]['restorationTime']).to eq 124.5

    expect(h[1]['benchName']).to eq "Rnd 0% Wallet"
    expect(h[1]['listingAddressesTime']).to eq 0.0004571

    expect(h[2]['benchName']).to eq "Rnd 0.1% Wallet"
    expect(h[2]['estimatingFeesTime']).to eq 0.1422
  end
end

describe Helpers::Readers::Latencies do
  it "read_to_hash" do
    res = File.read("#{Dir.pwd}/tests/artifacts/latency.log")
    h = Latencies.read_to_hash res

    v = h['+++ Run benchmark - jormungandr']['Non-cached run']['getNetworkInfo']
    expect(v).to eq 10.4

    v = h['+++ Run benchmark - jormungandr']['Latencies for 10 fixture wallets scenario']['listStakePools']
    expect(v).to eq 269.8

    v = h['+++ Run benchmark - shelley']['Non-cached run']['getNetworkInfo']
    expect(v).to eq 28.2

    v = h['+++ Run benchmark - shelley']['Latencies for 2 fixture wallets with 10 txs scenario']['listAddresses']
    expect(v).to eq 6.5

    v = h['+++ Run benchmark - shelley']['Latencies for 2 fixture wallets scenario']['postTransactionFee']
    expect(v).to eq 118.1

    v = h['+++ Run benchmark - shelley']['Latencies for 2 fixture wallets with 200 utxos scenario']['listTransactions']
    expect(v).to eq 101.9

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
