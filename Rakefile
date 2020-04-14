require "sequel/core"

require_relative "env"
require_relative "helpers/buildkite"
require_relative "helpers/data_transfer"

include Helpers::DataTransfer

namespace :db do
  desc "Run DB migrations"
  task :migrate, [:version] do |t, args|
    Sequel.extension :migration
    version = args[:version].to_i if args[:version]
    Sequel.connect(DB_PATH) do |db|
      Sequel::Migrator.run(db, "db/migrations", target: version)
    end
  end
end

namespace :bk do
  desc "Get results from buildkite for range of builds"
  task :range, [:min_build_no, :max_build_no] do |t, args|
    bk = Helpers::Buildkite.new
    DB = Sequel.connect(DB_PATH)
    min = args[:min_build_no].to_i if args[:min_build_no]
    max = args[:max_build_no].to_i if args[:max_build_no]
    (min..max).each do |build_no|
      puts "Build: #{build_no}"
      res = bk.get_restoration_results_hash(build_no)
      Helpers::DataTransfer::insert_into_db(res, DB)
    end
  end

  desc "Get latest results from buildkite"
  task :latest do
    bk = Helpers::Buildkite.new
    DB = Sequel.connect(DB_PATH)
    nightly_builds = DB[:nightly_builds]
    last_build_in_db = nightly_builds.all.reverse.first[:build_no] if nightly_builds.first
    last_builds_from_bk = bk.get_pipline_build_numbers
    builds = Helpers::DataTransfer::find_builds_to_transfer(last_build_in_db, last_builds_from_bk).reverse
    if builds.empty?
      puts "No new build..."
    else
      builds.each do |build_no|
        puts "Build: #{build_no}"
        res = bk.get_restoration_results_hash(build_no)
        Helpers::DataTransfer::insert_into_db(res, DB)
      end
    end
  end
end
