require "buildkit"
require "httparty"

require_relative "../env"
require_relative "readers"

module Helpers
  class Buildkite
    include HTTParty
    include Helpers::Readers

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

    def get_artifacts(build_no, job_id)
      @client.job_artifacts(@org, @pipeline, build_no, job_id)
    end

    # get artifact url from buildkite build by name
    def get_artifact_url(build_no, job_id, filename)
      self.get_artifacts(build_no, job_id).select{|a| a[:filename] == filename}.map{|a| a[:download_url]}[0]
    end

    # once you have artifact url, you can get the AWS direct url where the artifact is really stored
    def get_aws_url(url)
      r = self.class.get(url, follow_redirects: false,
      :headers => { 'Authorization' => "Bearer #{BUILDKITE_API_TOKEN}" } )
      r.to_hash['url']
    end

    # get the final download artifact (from AWS), using build_no and filename as params
    def get_artifact_download_url(build_no, job_id, filename)
      begin
        url = self.get_artifact_url(build_no, job_id, filename)
        self.get_aws_url(url)
      rescue
        nil
      end
    end

    def download_artifact(url)
      self.class.get(url)
    end

    def get_restoration_results_from_artifact(build_no, job_id, artifact_name)
      begin
        url = self.get_artifact_download_url(build_no, job_id, artifact_name)
        res = self.download_artifact(url)
      rescue
        puts "No url for artifact: #{artifact_name}"
      end
      results = Restorations::Row.new
      time_seq_key, time_1per_key, time_2per_key = Restorations.restoration_keys(artifact_name)
      begin
        r = Restorations.read_to_hash(res.body)
        results.time_seq = r[time_seq_key].to_f
        results.time_1per = r[time_1per_key].to_f
        results.time_2per = r[time_2per_key].to_f
      rescue
        puts "No results for artifact: #{artifact_name}"
      end
       results
    end

    def get_restoration_results_hash(build_no)
      build_details =  self.get_pipeline_build(build_no)
      jobs = Jobs.get_pipeline_build_jobs build_details
      build = Builds::Row.new(build_no, build_details[:created_at], build_details[:commit])

      mainnet_results = self.get_restoration_results_from_artifact build_no,
                        jobs["Restore benchmark - mainnet"],
                        'restore-byron-mainnet.txt'
      testnet_results = self.get_restoration_results_from_artifact build_no,
                        jobs["Restore benchmark - testnet"],
                        "restore-byron-testnet.txt"

      { build: build,
        mainnet_restores: mainnet_results,
        testnet_restores: testnet_results
      }
    end
  end
end

# include Helpers
# bk = Buildkite.new
# build_details = bk.get_pipeline_build 477
# p bk.get_pipeline_build_jobs build_details
