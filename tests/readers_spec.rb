require_relative 'spec_helper'

include Helpers::Readers

describe Helpers::Readers::Restorations do

  it "read_to_hash - mainnet" do
    res = File.read("#{Dir.pwd}/tests/artifacts/restoration-mainnet.txt")
    h = Restorations.read_to_hash res

    expect(h[0]['benchName']).to eq "baseline"
    expect(h[0]['restoreTime']).to eq 2343.0

    expect(h[1]['benchName']).to eq "0-percent-seq"
    expect(h[1]['restoreTime']).to eq 3654.0

    expect(h[2]['benchName']).to eq "0.01-percent-seq"
    expect(h[2]['listTransactionsLimitedTime']).to eq 0.3379

    expect(h[3]['benchName']).to eq "0.01-percent-rnd"
    expect(h[3]['restoreTime']).to eq 8429.0

  end

  it "read_to_hash - testnet" do
    res = File.read("#{Dir.pwd}/tests/artifacts/restoration-testnet.txt")
    h = Restorations.read_to_hash res

    expect(h[0]['benchName']).to eq "baseline"
    expect(h[0]['restoreTime']).to eq 3131

    expect(h[1]['benchName']).to eq "0-percent-seq"
    expect(h[1]['restoreTime']).to eq 124.6

    expect(h[2]['benchName']).to eq "0-percent-rnd"
    expect(h[2]['listAddressesTime']).to eq 0.0005528

    expect(h[3]['benchName']).to eq "0.1-percent-rnd"
    expect(h[3]['estimateFeesTime']).to eq 0.02367
  end
end

describe Helpers::Readers::Latencies do
  it "read_to_hash" do
    res = File.read("#{Dir.pwd}/tests/artifacts/latency_NB1268.log")
    # res = File.read("#{Dir.pwd}/tests/artifacts/latency.log")
    h = Latencies.read_to_hash res

    v = h['+++ Run benchmark - shelley']['Non-cached run']['getNetworkInfo']
    expect(v).to eq 27.0

    v = h['+++ Run benchmark - shelley']['Latencies for 2 fixture wallets with 10 txs scenario']['listAddresses']
    expect(v).to eq 1.5

    v = h['+++ Run benchmark - shelley']['Latencies for 2 fixture wallets scenario']['postTransactionFee']
    expect(v).to eq 21.5

    v = h['+++ Run benchmark - shelley']['Latencies for 2 fixture wallets with 200 utxos scenario']['listTransactions']
    expect(v).to eq 49.6

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
