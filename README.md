
<a href="https://github.com/piotr-iohk/benchmark_app/actions?query=workflow%3ATests">
  <img src="https://github.com/piotr-iohk/benchmark_app/workflows/Tests/badge.svg" />
</a>

<a href="https://codecov.io/gh/piotr-iohk/benchmark_app">
  <img src="https://codecov.io/gh/piotr-iohk/benchmark_app/branch/master/graph/badge.svg" />
</a>

# benchmark app

Graphs of [cardano-wallet](https://github.com/input-output-hk/cardano-wallet) benchmarks from [nightly builds](https://buildkite.com/input-output-hk/cardano-wallet-nightly).

<br/>

http://ec2-18-156-193-207.eu-central-1.compute.amazonaws.com:5555

<br/>

<img src="https://github.com/piotr-iohk/benchmark_app/blob/master/.github/1.png" />

## Test

```bash
# Install
git clone https://github.com/piotr-iohk/benchmark_app.git
cd benchmark_app
bundle install

# Configure
export BENCH_DB_PATH=sqlite:/tmp/test.db
export BUILDKITE_API_TOKEN=fake_token
rake db:migrate

# To set up data being downloaded from buildkite set up as a cron job or
# in heroku scheduler
rake bk:latest

# Run all tests
rspec tests

# Open code coverage report
xdg-open coverage/index.html
```
