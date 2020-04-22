require 'yaml'

##
# helper module for serializing data from buildkite
module Helpers
  module Readers

    module Builds
      class Row
        attr_accessor :number, :revision, :created_at

        def initialize(number, created_at, revision)
          @number = number
          @revision = revision
          @created_at = created_at
        end
      end
    end

    module Restorations
      class Row
        attr_accessor :time_seq, :time_1per, :time_2per
      end

      def read_to_hash(benchmark_string)
        YAML.load(benchmark_string).to_hash['All results'].map { |k,v| [k, v.to_f] }.to_h
      end

      def restoration_keys(artifact_name)
        case artifact_name
        when 'restore-byron-mainnet.txt'
          ['restore mainnet seq',
           'restore mainnet 1% ownership',
           'restore mainnet 2% ownership']
        when 'restore-byron-testnet.txt'
          ['restore testnet (1097911063) seq',
           'restore testnet (1097911063) 1% ownership',
           'restore testnet (1097911063) 2% ownership']
        else
          raise "Wrong artifact name: #{artifact_name}"
        end
      end

      module_function :read_to_hash, :restoration_keys
    end # Restoration

    module Latencies
      LATENCIES = [ ]
      def read_to_hash(str)
        lines = []
        str.split(/\r?\n|\r/).map{|l| l.strip}.each do |l|
          if (l.include? "-") && (not (l.include? "+++ Run benchmark - jormungandr"))
            lines << l.split("-").map{|l| l.strip}
          else
            lines << [l]
          end
        end

        h_top = {}
        h_main = {}
        h_latencies = {}
        key = "t"
        lines.reverse.each_with_index do |l, i|
          if l.size == 2
            h_latencies[l[0]] = l[1].to_f
            if (i == lines.size - 1) # store the last latency
              h_main[key] = h_latencies
            end
          else
            if (l[0] != key)
              key = l[0]
              unless h_latencies.empty?
                h_main[key] = h_latencies
              end
              h_latencies = {}
            end

            if (l[0] == "Random wallets") || (l[0] == "Icarus wallets") ||
               (l[0] == "+++ Run benchmark - jormungandr")
              h_top[l[0]] = h_main
              h_main = {}
            end
          end
        end
        h_top
      end

      module_function :read_to_hash
    end # Latency

    module Jobs
      ##
      # build_details <- get_pipeline_build(build_no)
      # returns: {job_name => job_id}
      def get_pipeline_build_jobs(build_details)
        build_details[:jobs].map{|j| [j[:name], j[:id]]}.to_h
      end

      module_function :get_pipeline_build_jobs
    end # Jobs
  end # Readers
end # Helpers
