require 'sinatra'
require 'sequel'
require 'chartkick'

require_relative "env"
require_relative "helpers/buildkite"

class App < Sinatra::Base
  include Helpers
  set :root, File.dirname(__FILE__)
  enable :sessions

  DB = Sequel.connect(DB_PATH)

  # helpers Helpers::Buildkite
  # register Sinatra::App::Routing::Main

  get "/" do
    # size = DB[:nightly_builds].all.size
    # erb :index, { :locals => { :size => size } }
    redirect "/nightbuilds"
  end

  get "/nightbuilds" do
    dataset = DB[:nightly_builds].all.reverse
    erb :nightbuilds, { :locals => { :dataset => dataset } }
  end

  get "/nightbuilds/:id" do
    build_no = params[:id]
    builds = DB[:nightly_builds]
    mainnet = DB[:nightly_builds].join(:mainnet_restores, nightly_build_id: :nightly_build_id).
                                  where(build_no: build_no)
    testnet = DB[:nightly_builds].join(:testnet_restores, nightly_build_id: :nightly_build_id).
                                  where(build_no: build_no)
    bk = Buildkite.new
    jobs = bk.get_pipeline_build_jobs bk.get_pipeline_build(build_no)
    mainnet_svg = bk.get_artifact_download_url build_no,
                  jobs["Restore benchmark - mainnet"],
                  "restore-byron-mainnet.svg"
    testnet_svg = bk.get_artifact_download_url build_no,
                  jobs["Restore benchmark - testnet"],
                  "restore-byron-testnet.svg"
    mainnet_plot = bk.get_artifact_download_url build_no,
                  jobs["Restore benchmark - mainnet"],
                  "plot.svg"
    testnet_plot = bk.get_artifact_download_url build_no,
                  jobs["Restore benchmark - testnet"],
                  "plot.svg"
    erb :nightbuild, { :locals => { :builds => builds,
                                    :testnet => testnet,
                                    :mainnet => mainnet,
                                    :svg_urls => [mainnet_svg, testnet_svg],
                                    :plot_urls => [mainnet_plot, testnet_plot] } }
  end

  get "/mainnet-restoration" do
    dataset = DB[:mainnet_restores].join_table(:inner, DB[:nightly_builds], [:nightly_build_id]).
                                    exclude(time_seq: nil, time_1per: nil, time_2per: nil)
    erb :restoration, { :locals => { :dataset => dataset } }
  end

  get "/testnet-restoration" do
    dataset = DB[:testnet_restores].join_table(:inner, DB[:nightly_builds], [:nightly_build_id]).
                                    exclude(time_seq: nil, time_1per: nil, time_2per: nil)
    erb :restoration, { :locals => { :dataset => dataset } }
  end

end
