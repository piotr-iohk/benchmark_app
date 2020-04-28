require_relative '../app'  # <-- your sinatra app
require_relative 'spec_helper'
require 'rspec'
require 'rack/test'

describe 'The HelloWorld App' do
  include Rack::Test::Methods

  def app
    BenchmarkApp
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
