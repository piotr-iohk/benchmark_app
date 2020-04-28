require 'sinatra'
require 'sequel'
require 'chartkick'

require_relative "env"
require_relative "helpers/app"
require_relative "helpers/buildkite"
require_relative "helpers/readers"

class BenchmarkApp < Sinatra::Base
  include Helpers
  include Helpers::Readers
  set :root, File.dirname(__FILE__)
  enable :sessions
  helpers Helpers::App

  DB = Sequel.connect(DB_PATH)

  # register Sinatra::App::Routing::Main

  get "/" do
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
    jobs = Jobs.get_pipeline_build_jobs bk.get_pipeline_build(build_no)
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
    erb :restoration_graphs, { :locals => { :dataset => dataset } }
  end

  get "/testnet-restoration" do
    dataset = DB[:testnet_restores].join_table(:inner, DB[:nightly_builds], [:nightly_build_id]).
                                    exclude(time_seq: nil, time_1per: nil, time_2per: nil)
    erb :restoration_graphs, { :locals => { :dataset => dataset } }
  end

  get "/latency" do
    latency_category = params[:latency_category]
    latency_benchmark = params[:latency_benchmark]
    latency_measurement = params[:latency_measurement]

    sql = %{
      select build_no, c.name as category, b.name as benchmark, "listWallets", "getWallet",
	   "getUTxOsStatistics", "listAddresses", "listTransactions", "postTransactionFee", "getNetworkInfo"
        from latency_measurements as m
        join nightly_builds as n on m.nightly_build_id = n.nightly_build_id
        join latency_benchmarks as b on m.latency_benchmark_id = b.latency_benchmark_id
        join latency_categories as c on m.latency_category_id = c.latency_category_id
    }
    dataset = DB[sql]
    latency_categories = DB[:latency_categories]
    latency_benchmarks = DB[:latency_benchmarks]
    latency_measurements = [ "all",
                             "listWallets",
                             "getWallet",
                             "getUTxOsStatistics",
                             "listAddresses",
                             "listTransactions",
                             "postTransactionFee",
                             "getNetworkInfo" ]

    erb :latency_graphs, { :locals => { :dataset => dataset,
                                        :latency_categories => latency_categories,
                                        :latency_benchmarks => latency_benchmarks,
                                        :latency_measurements => latency_measurements
                                         }}

  end

end
