if ENV["APP_ENV"] == "test"
  DB_PATH = 'sqlite:/tmp/data.db'
  BUILDKITE_API_TOKEN = '111111'
else
  DB_PATH = ENV.fetch("BENCH_DB_PATH") # ENV var for sqlite db file
  BUILDKITE_API_TOKEN = ENV.fetch("BUILDKITE_API_TOKEN")
end
