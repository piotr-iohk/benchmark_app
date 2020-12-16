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

  get "/database" do
    last_build = DB[:nightly_builds].all.reverse.first[:build_no]
    redirect "/database/#{last_build}"
  end

  get "/database/:id" do
    build_numbers = DB[:nightly_builds].all.map{ |b| b[:build_no]}
    build_no = params[:id].to_i
    bk = Buildkite.new

    begin
      jobs = Jobs.get_pipeline_build_jobs bk.get_pipeline_build(build_no)
      db_chart_link = bk.get_artifact_download_url build_no,
                    jobs["Database benchmark"],
                    "bench-db.html"
    rescue
      db_chart_link = nil
      session[:error] = "Buildkite connection failed for build_no: #{params[:id]}."
    end
    erb :database, { :locals => { :build_numbers => build_numbers,
                                  :build_no => build_no,
                                  :db_chart_link => db_chart_link } }
  end

  get "/nightbuilds" do
    dataset = DB[:nightly_builds].order(Sequel.desc(:build_no)).all
    erb :nightbuilds, { :locals => { :dataset => dataset } }
  end

  get "/nightbuilds/:id" do
    build_no = params[:id].to_i
    builds = DB[:nightly_builds]
    mainnet = DB[:nightly_builds].join(:mainnet_restores_new, nightly_build_id: :nightly_build_id).
                                  where(build_no: build_no)
    testnet = DB[:nightly_builds].join(:testnet_restores_new, nightly_build_id: :nightly_build_id).
                                  where(build_no: build_no)
    bk = Buildkite.new
    begin
      jobs = Jobs.get_pipeline_build_jobs bk.get_pipeline_build(build_no)
      mainnet_svg = bk.get_artifact_download_url build_no,
                    jobs[MAINNET_RESTORE_JOB],
                    "restore-mainnet.svg"
      testnet_svg = bk.get_artifact_download_url build_no,
                    jobs[TESTNET_RESTORE_JOB],
                    "restore-testnet.svg"
      mainnet_plot = bk.get_artifact_download_url build_no,
                    jobs[MAINNET_RESTORE_JOB],
                    "plot.svg"
      testnet_plot = bk.get_artifact_download_url build_no,
                    jobs[TESTNET_RESTORE_JOB],
                    "plot.svg"
    rescue
      mainnet_svg, testnet_svg, mainnet_plot, testnet_plot = nil
      session[:error] = "Buildkite connection failed..."
    end
    erb :nightbuild, { :locals => { :builds => builds,
                                    :testnet => testnet,
                                    :mainnet => mainnet,
                                    :svg_urls => [mainnet_svg, testnet_svg],
                                    :plot_urls => [mainnet_plot, testnet_plot] } }
  end

  get "/mainnet-restoration" do
    dataset = DB[:mainnet_restores_new].
              join(:nightly_builds, nightly_build_id: :nightly_build_id).
              order(Sequel.asc(:build_no))
    erb :restoration_graphs, { :locals => { :dataset => dataset } }
  end

  get "/testnet-restoration" do
    dataset = DB[:testnet_restores_new].
              join(:nightly_builds, nightly_build_id: :nightly_build_id).
              order(Sequel.asc(:build_no))
    erb :restoration_graphs, { :locals => { :dataset => dataset } }
  end

  get "/latency" do
    sql = %{
      select build_no, c.name as category, b.name as benchmark,
             #{LATENCY_MEASUREMENTS.map{|m| "\"" + m + "\""}.join(", ")}
        from latency_measurements as m
        join nightly_builds as n on m.nightly_build_id = n.nightly_build_id
        join latency_benchmarks as b on m.latency_benchmark_id = b.latency_benchmark_id
        join latency_categories as c on m.latency_category_id = c.latency_category_id
      order by build_no ASC
    }
    dataset = DB[sql]
    latency_categories = DB[:latency_categories].
                              where(name: LATENCY_CATEGORIES[0]).
                              or(name: LATENCY_CATEGORIES[1])
    latency_benchmarks = DB[:latency_benchmarks]
    latency_measurements = [ "all" ] + LATENCY_MEASUREMENTS

    erb :latency_graphs, { :locals => { :dataset => dataset,
                                        :latency_categories => latency_categories,
                                        :latency_benchmarks => latency_benchmarks,
                                        :latency_measurements => latency_measurements
                                         }}
  end

end
