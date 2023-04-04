require_relative 'spec_helper'

Capybara.app = BenchmarkApp
# Capybara.default_driver = :selenium
# Capybara.server = :webrick

include Helpers

describe 'On the Benchmark App', type: :feature do

  def is_active page
    "//a[contains(@class,'active') and @href='#{page}']"
  end

  before(:all) do
    # Insert data
    DB = Sequel.connect(DB_PATH)
    testnet = File.read("#{Dir.pwd}/tests/artifacts/restoration-testnet.txt")
    mainnet = File.read("#{Dir.pwd}/tests/artifacts/restoration-mainnet.txt")
    latency = File.read("#{Dir.pwd}/tests/artifacts/latency_NB1268.log")

    @build = { build_no: 111,
               datetime: Time.now,
               rev: "2e258c3e5852dd758a7a81dc8be35bd729c58241",
               build_status: "passed"
            }
    @mainnet_results = Readers::Restorations.read_to_hash mainnet
    @testnet_results = Readers::Restorations.read_to_hash testnet
    @latency_results = Readers::Latencies.read_to_hash latency
    results = { build: @build,
                mainnet_restores: @mainnet_results,
                testnet_restores: @testnet_results,
                latency_results: @latency_results
              }
    2.times { Helpers::DataTransfer.insert_into_db(results, DB) }
  end

  after(:all) do
    # Purge data
    DB[:latency_measurements].delete
    DB[:latency_benchmarks].delete
    DB[:latency_categories].delete
    DB[:mainnet_restores_new].delete
    DB[:nightly_builds].delete
  end

  it "Main page redirects to Nightbuilds" do
    visit '/'
    expect(page).to have_xpath("//h4[text()='Total: 1']")
    expect(page).to have_xpath("//a[@href='/nightbuilds/#{@build[:build_no]}']")
    click_link 'Nightbuilds'
    expect(page).to have_xpath("//h4[text()='Total: 1']")
    expect(page).to have_xpath("//a[@href='/nightbuilds/#{@build[:build_no]}']")
  end

  it "I can visit pages directly" do
    visit '/'
    expect(page).to have_xpath(is_active "/nightbuilds")
    visit '/nightbuilds'
    expect(page).to have_xpath(is_active "/nightbuilds")
    visit '/nightbuilds/fake'
    expect(page).to have_xpath(is_active "/nightbuilds")
    visit "/nightbuilds/#{@build[:build_no]}"
    expect(page).to have_xpath(is_active "/nightbuilds")
    visit '/latency'
    expect(page).to have_xpath(is_active "/latency")
    visit '/latency?latency_category=3&latency_benchmark=12&latency_measurement=listWallets'
    expect(page).to have_xpath(is_active "/latency")
    # visit '/testnet-restoration'
    # expect(page).to have_xpath(is_active "/testnet-restoration")
    visit '/mainnet-restoration'
    expect(page).to have_xpath(is_active "/mainnet-restoration")
  end

  it "Latency form has proper data" do
    visit '/'
    click_link "Latency"
    expect(page).to have_xpath("//form")
    wal_types_inserted = @latency_results.keys
    bench_types_inserted = @latency_results['+++ Run benchmark - shelley'].keys
    meas_types_inserted = @latency_results['+++ Run benchmark - shelley']['Latencies for 2 fixture wallets scenario'].keys

    wal_types_on_page = all(:xpath, "//select[@name='latency_category']/option").map{|e| e.text}
    bench_types_on_page = all(:xpath, "//select[@name='latency_benchmark']/option").map{|e| e.text}
    meas_types_on_page = all(:xpath, "//select[@name='latency_measurement']/option").map{|e| e.text}

    wal_types_inserted.each {|w| expect(wal_types_on_page.include? w).to eq true}
    bench_types_inserted.each {|w| expect(bench_types_on_page.include? w).to eq true}
    meas_types_inserted.each {|w| expect(meas_types_on_page.include? w).to eq true}
  end

  it "Can draw Latency graphs" do
    visit '/'
    click_link "Latency"
    expect(page).to have_xpath("//form")
    click_button "Draw"
    expect(page).to have_xpath("//form")
  end

  it "Fake nightbuild shows nicely it does not exist" do
    visit '/nightbuilds/fake'
    expect(page).to have_text("No such nightly build: fake.")
  end

  it "Proper nightbuild shows nice details" do
    visit '/'
    expect(page).to have_link(@build[:build_no].to_s)
    expect(page).to have_link(@build[:rev][0..7].to_s)
    expect(page).to have_text(@build[:datetime].to_s)
    expect(page).to have_link(@build[:build_status].to_s)
    click_link @build[:build_no].to_s
    expect(page).to have_link(@build[:build_no].to_s)
    expect(page).to have_link(@build[:rev].to_s)
    expect(page).to have_text(@build[:datetime].to_s)
    expect(page).to have_link(@build[:build_status].to_s)
  end

  it "Mainnet restoration graphs" do
    visit '/'
    click_link "Mainnet"
    expect(page).to have_xpath(is_active "/mainnet-restoration")
  end

  # it "Testnet restoration graphs" do
  #   visit '/testnet-restoration'
  #   expect(page).to have_xpath(is_active "/testnet-restoration")
  # end

  it "Database graphs" do
    visit '/'
    click_link "Database"
    expect(page).to have_link(@build[:build_no])
  end

  it "Database graphs - fake NB id" do
    visit '/database/fake'
    expect(page).to have_text("Buildkite connection failed for build_no: fake.")
  end

end
