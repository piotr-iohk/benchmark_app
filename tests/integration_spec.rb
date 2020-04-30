require_relative '../app'  # <-- your sinatra app
require_relative 'spec_helper'
require 'rspec'
require 'rack/test'

describe 'The Benchmark App' do
  include Rack::Test::Methods

  def app
    BenchmarkApp
  end

  before(:all) do
    # Insert data
    DB = Sequel.connect(DB_PATH)
    testnet = File.read("#{Dir.pwd}/tests/artifacts/restoration-testnet.txt")
    mainnet = File.read("#{Dir.pwd}/tests/artifacts/restoration-mainnet.txt")
    latency = File.read("#{Dir.pwd}/tests/artifacts/latency.log")

    build = { build_no: 111,
              datetime: Time.now,
              rev: "2e258c3e5852dd758a7a81dc8be35bd729c58241"
            }
    mainnet_results = Readers::Restorations.read_to_hash mainnet, "mainnet"
    testnet_results = Readers::Restorations.read_to_hash testnet, "testnet"
    latency_results = Readers::Latencies.read_to_hash latency
    results = { build: build,
                mainnet_restores: mainnet_results,
                testnet_restores: testnet_results,
                latency_results: latency_results
              }
    2.times { Helpers::DataTransfer.insert_into_db(results, DB) }
  end

  it "Main" do
    get '/'
    # expect(last_response).to be_ok
  end

  it "Latency" do
    get '/latency'
    # expect(last_response).to be_ok
  end

  it "Nightbuilds" do
    get '/nightbuilds'
    # expect(last_response).to be_ok
  end

  it "Nightbuilds/1" do
    get '/nightbuilds/1'
    get '/nightbuilds/111'
    # expect(last_response).to be_ok
  end

  it "Mainnet" do
    get '/mainnet-restoration'
    # expect(last_response).to be_ok
  end

  it "Testnet" do
    get '/testnet-restoration'
    # expect(last_response).to be_ok
  end
end
