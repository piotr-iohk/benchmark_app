require "sequel/core"

require_relative "env"
require_relative "helpers/buildkite"
require_relative "helpers/data_transfer"
require_relative "helpers/data_cleaner"

include Helpers

namespace :db do
  ##
  # rake db:migrate
  desc "Run DB migrations"
  task :migrate, [:version] do |t, args|
    Sequel.extension :migration
    version = args[:version].to_i if args[:version]
    Sequel.connect(DB_PATH) do |db|
      Sequel::Migrator.run(db, "db/migrations", target: version)
    end
  end

  ##
  # rake db:clean[555]
  desc "Remove all nightbuilds (with all measurements) older than nb"
  task :clean, [:nb] do |t, args|
    nb = args[:nb]
    db_conn = Sequel.connect(DB_PATH)
    Helpers::DataCleaner.remove(db_conn, date)
  end
end

namespace :bk do

  desc "Get results from buildkite for range of builds"
  task :range, [:min_build_no, :max_build_no, :skip] do |t, args|
    bk = Helpers::Buildkite.new
    DB = Sequel.connect(DB_PATH)
    min = args[:min_build_no].to_i if args[:min_build_no]
    max = args[:max_build_no].to_i if args[:max_build_no]
    case args[:skip]
    when "skip_latency"
      skip = {skip_latency: true}
    when "skip_restorations"
      skip = {skip_mainnet: true, skip_testnet: true}
    else
      skip = {}
    end
    (min..max).each do |build_no|
      puts "Build: #{build_no}"
      res = bk.get_benchmark_results_hash(build_no)
      Helpers::DataTransfer.insert_into_db(res, DB, skip)
    end
  end
  
  ##
  # rake bk:latest
  desc "Get latest results from buildkite"
  task :latest do
    bk = Helpers::Buildkite.new
    DB = Sequel.connect(DB_PATH)
    nightly_builds = DB[:nightly_builds]
    last_build_in_db = nightly_builds.all.reverse.first[:build_no] if nightly_builds.first
    last_builds_from_bk = bk.get_pipline_build_numbers
    builds = Helpers::DataTransfer.find_builds_to_transfer(last_build_in_db, last_builds_from_bk).reverse
    if builds.empty?
      puts "No new build..."
    else
      builds.each do |build_no|
        puts "Build: #{build_no}"
        state = bk.get_pipeline_build(build_no)[:state]
        if ["passed", "failed"].include? state
          res = bk.get_benchmark_results_hash(build_no)
          Helpers::DataTransfer.insert_into_db(res, DB)
        else
          puts "  Skipping, build state = #{state}."
        end
      end
    end
  end

  desc "Latencies for existing builds"
  task :latencies do
    bk = Helpers::Buildkite.new
    DB = Sequel.connect(DB_PATH)
    builds = DB[:nightly_builds].all.map { |b| b[:build_no]}
    builds.each do |build_no|
      puts "Build: #{build_no}"
      state = bk.get_pipeline_build(build_no)[:state]
      if ["passed", "failed"].include? state
        res = bk.get_benchmark_results_hash(build_no)
        Helpers::DataTransfer.insert_into_db(res, DB, {skip_mainnet: true, skip_testnet: true})
      else
        puts "  Skipping, build state = #{state}."
      end
    end
  end

  desc "Update build statuses"
  task :update_build_statuses do
    bk = Helpers::Buildkite.new
    DB = Sequel.connect(DB_PATH)
    builds = DB[:nightly_builds].all.map { |b| b[:build_no]}
    builds.each do |build_no|
      state = bk.get_pipeline_build(build_no)[:state]
      puts "Build: #{build_no} => #{state}"
      DB[:nightly_builds].where(build_no: build_no).
                          update(build_status: state)
    end
  end

end
