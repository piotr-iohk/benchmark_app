require "buildkit"
require "httparty"

require_relative "../env"

module Helpers
  class Build
    attr_accessor :number, :revision, :created_at

    def initialize(number, created_at, revision)
      @number = number
      @revision = revision
      @created_at = created_at
    end
  end

  class RestorationTimes
    attr_accessor :time_seq, :time_1per, :time_2per

    def initialize(time_seq, time_1per, time_2per)
      @time_seq = time_seq
      @time_1per = time_1per
      @time_2per = time_2per
    end
  end

  class Buildkite
    include HTTParty

    def initialize
      @org = 'input-output-hk'
      @pipeline = 'cardano-wallet-nightly'
      @client = Buildkit.new(token: BUILDKITE_API_TOKEN)
    end

    def get_pipline_build_numbers(options = {branch: "master"})
      @client.pipeline_builds(@org, @pipeline, options).map{|b| b[:number]}
    end

    def get_pipeline_build(build_no)
      @client.build(@org, @pipeline, build_no)
    end

    def get_artifacts(build_no)
      @client.artifacts(@org, @pipeline, build_no)
    end

    def get_artifact_download_url(build_no, filename)
      self.get_artifacts(build_no).select{|a| a[:filename] == filename}.map{|a| a[:download_url]}[0]
    end

    def download_artifact(url)
      r = self.class.get(url, follow_redirects: false,
      :headers => { 'Authorization' => "Bearer #{BUILDKITE_API_TOKEN}" } )
      aws_url = r.to_hash['url']
      self.class.get(aws_url)
    end

    def get_restoration_results_from_artifact(build_no, artifact_name)
      if artifact_name == "restore-byron-mainnet.txt"
        time_seq_key = 'restore mainnet seq'
        time_1per_key = 'restore mainnet 1% ownership'
        time_2per_key = 'restore mainnet 2% ownership'
      elsif artifact_name == "restore-byron-testnet.txt"
        time_seq_key = 'restore testnet (1097911063) seq'
        time_1per_key = 'restore testnet (1097911063) 1% ownership'
        time_2per_key = 'restore testnet (1097911063) 2% ownership'
      end

      url = self.get_artifact_download_url(build_no, artifact_name)
      begin
        res = self.download_artifact(url)
      rescue
        puts "No url for artifact: #{artifact_name}"
      end

      begin
        r = YAML.load(res.body).to_hash['All results']
        time_seq = r[time_seq_key].to_f
        time_1per = r[time_1per_key].to_f
        time_2per = r[time_2per_key].to_f
        results = RestorationTimes.new(time_seq, time_1per, time_2per)
      rescue
        puts "No results for artifact: #{artifact_name}"
      end
       results
    end

    def get_restoration_results_hash(build_no)
      build_details =  self.get_pipeline_build(build_no)
      build = Build.new(build_no, build_details[:created_at], build_details[:commit])
      mainnet_results = self.get_restoration_results_from_artifact build_no, 'restore-byron-mainnet.txt'
      testnet_results = self.get_restoration_results_from_artifact build_no, 'restore-byron-testnet.txt'

      result = { build: build,
                 mainnet_restores: mainnet_results,
                 testnet_restores: testnet_results
               }
      result
    end
  end
end
