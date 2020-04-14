require 'sinatra'
require 'sequel'
require 'chartkick'

require_relative "env"

# connect to a database
DB = Sequel.sqlite(DB_PATH)

class App < Sinatra::Base

  set :root, File.dirname(__FILE__)
  enable :sessions

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
