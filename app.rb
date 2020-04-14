require 'sinatra'
require 'sequel'
require 'chartkick'

require_relative "env"

class App < Sinatra::Base

  set :root, File.dirname(__FILE__)
  enable :sessions

  DB = Sequel.connect(DB_PATH)

  # helpers Sinatra::App::Helpers
  # register Sinatra::App::Routing::Main

  get "/" do
    redirect '/mainnet-restoration'
  end

  get "/mainnet-restoration" do
    dataset = DB[:mainnet_restores].join_table(:inner, DB[:nightly_builds], [:nightly_build_id])
    erb :restoration, { :locals => { :dataset => dataset } }
  end

  get "/testnet-restoration" do
    dataset = DB[:testnet_restores].join_table(:inner, DB[:nightly_builds], [:nightly_build_id])
    erb :restoration, { :locals => { :dataset => dataset } }
  end

end
