require 'yaml'
require_relative "../env"

##
# helper module for serializing data from buildkite
module Helpers
  module Readers
    module Restorations
      def read_to_hash(benchmark_string, mainnet_or_testnet)
        # remove last line if it includes log entry "Terminating child process"
        str = benchmark_string.strip.split("\n")
        if str.last.include? "Terminating child process"
          str = str - [str.pop]
        end
        str = str.join("\n")

        r = YAML.load(str).to_hash['All results'].map { |k,v| [k, v.to_f] }.to_h
        time_seq_key, time_rnd_key, time_1per_key, time_2per_key = restoration_keys(mainnet_or_testnet)
        { time_seq: r[time_seq_key].to_f,
          time_rnd: r[time_rnd_key].to_f,
          time_1per: r[time_1per_key].to_f,
          time_2per: r[time_2per_key].to_f
        }
      end

      def restoration_keys(artifact_name)
        case artifact_name
        when MAINNET_RESTORE_FILE, 'mainnet'
          ['restore mainnet seq',
           'restore mainnet rnd',
           'restore mainnet 1% ownership',
           'restore mainnet 2% ownership']
        when TESTNET_RESTORE_FILE, 'testnet'
          ['restore testnet (1097911063) seq',
           'restore testnet (1097911063) rnd',
           'restore testnet (1097911063) 1% ownership',
           'restore testnet (1097911063) 2% ownership']
        else
          raise "Wrong artifact name: #{artifact_name}"
        end
      end

      module_function :read_to_hash, :restoration_keys
    end # Restoration

    module Latencies
      def proper_log_line?(l)
        (LATENCY_CATEGORIES + LATENCY_BENCHMARKS + LATENCY_MEASUREMENTS).any?{|i| l.include? i }
      end

      def read_to_hash(str)
        # Clean the log output string from latency benchmark from trash
        proper_str = ''
        str.split(/\r?\n|\r/).map{|l| l.strip}.each do |l|
          if (proper_log_line? l)
            proper_str += "#{l}\n"
          end
        end

        # split cleaned log output into array where following item is a measurement
        lines = []
        proper_str.split(/\r?\n|\r/).map{|l| l.strip}.each do |l|
          if (l.include? "-") &&
             (not (l.include? LATENCY_CATEGORIES[0])) &&
             (not (l.include? LATENCY_CATEGORIES[1])) &&
             (not (l.include? LATENCY_BENCHMARKS[0]))
            lines << l.split("-").map{|l| l.strip}
          else
            lines << [l]
          end
        end

        h_top = {}
        h_main = {}
        h_latencies = {}
        latency_benchmarks = LATENCY_BENCHMARKS

        # build a hash from data
        lines.reverse.each_with_index do |l, i|
          if l.size == 2
            h_latencies[l[0]] = l[1].to_f
            if (i == lines.size - 1) # store the last latency
              h_main[key] = h_latencies
            end
          else
            if (latency_benchmarks.include? l[0])
              key = l[0]
              unless h_latencies.empty?
                h_main[key] = h_latencies
              end
              h_latencies = {}
            end

            if (l[0] == LATENCY_CATEGORIES[0]) ||
               (l[0] == LATENCY_CATEGORIES[1])
              h_top[l[0]] = h_main
              h_main = {}
            end
          end
        end
        h_top
      end

      module_function :read_to_hash, :proper_log_line?
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
