require 'yaml'
require_relative "../env"

##
# helper module for serializing data from buildkite
module Helpers
  module Readers
    
    def to_seconds(time_str)
      case
      when (time_str.include?("μs") || time_str.include?("Î¼s"))
        (time_str.to_f * 0.000001).round(8)
      when time_str.include?("ms")
        (time_str.to_f * 0.001).round(8)
      else
        time_str.to_f
      end
    end
    module_function :to_seconds

    module Api
      def read_to_hash(benchmark_string)
        bs = benchmark_string.gsub("number of addresses:", "number_of_addresses=").
                              gsub("number of transactions:", "number_of_transactions=")
        bs = bs.gsub(']', '').gsub('[', '')

        # transform to YAML
        str_arr = bs.strip.split("\n")
        str_arr_selected = str_arr - ["All results:"]
        str = str_arr_selected.join("\n").strip
        r = YAML.load(str)
        x = r.map do |s|
          # make time to be in seconds in case any key value starts with digit
          s[1].each do |k, v|
            if v.is_a?(String) && 
              (v.start_with?("0") || 
               v.start_with?("1") || 
               v.start_with?("2") || 
               v.start_with?("3") || 
               v.start_with?("4") || 
               v.start_with?("5") || 
               v.start_with?("6") || 
               v.start_with?("7") || 
               v.start_with?("8") || 
               v.start_with?("9"))
              s[1][k] = Helpers::Readers.to_seconds(v)
            end
          end
          s[1]
        end
        x
      end
      module_function :read_to_hash
    end

    module Restorations

      def read_to_hash(benchmark_string)

        bs = benchmark_string.gsub("number of addresses:", "number_of_addresses=").
                              gsub("number of transactions:", "number_of_transactions=")
        #remove all lines containing "" (because log entries sometimes spill into the file with measurements)
        bs = bs.gsub(/.*\n/, "")

        # remove garbage lines, all lines until last line is as expected
        str_arr = bs.strip.split("\n")
        until str_arr.last.include? "... 45000000000000000 0" do
          str_arr = str_arr[0..str_arr.rindex("")-1]
        end
        str_arr_selected = str_arr - ["All results:"]

        # rename top key to be unique
        str_arr_selected.each_with_index do |s, i|
          if s == "BenchRndResults:"
            str_arr_selected[i] = "BenchResults_#{i}:"
          end
          if s == "BenchSeqResults:"
            str_arr_selected[i] = "BenchResults_#{i}:"
          end
          if s == "BenchBaselineResults:"
            str_arr_selected[i] = "BenchResults_#{i}:"
          end
        end

        str = str_arr_selected.join("\n").strip
        r = YAML.load(str)

        # make time to be in seconds
        x = r.map do |s|
          s[1]['restoreTime'] = Helpers::Readers.to_seconds(s[1]['restoreTime']) if s[1]['restoreTime']
          s[1]['restoreTime'] = Helpers::Readers.to_seconds(s[1]['restorationTime']) if s[1]['restorationTime']
          s[1]['listAddressesTime'] = Helpers::Readers.to_seconds(s[1]['listAddressesTime']) if s[1]['listAddressesTime']
          s[1]['estimateFeesTime'] = Helpers::Readers.to_seconds(s[1]['estimateFeesTime']) if s[1]['estimateFeesTime']
          s[1]['readWalletTime'] = Helpers::Readers.to_seconds(s[1]['readWalletTime']) if s[1]['readWalletTime']
          s[1]['listTransactionsTime'] = Helpers::Readers.to_seconds(s[1]['listTransactionsTime']) if s[1]['listTransactionsTime']
          s[1]['listTransactionsLimitedTime'] = Helpers::Readers.to_seconds(s[1]['listTransactionsLimitedTime']) if s[1]['listTransactionsLimitedTime']
          s[1]['importOneAddressTime'] = Helpers::Readers.to_seconds(s[1]['importOneAddressTime']) if s[1]['importOneAddressTime']
          s[1]['importManyAddressesTime'] = Helpers::Readers.to_seconds(s[1]['importManyAddressesTime']) if s[1]['importManyAddressesTime']
          s[1]
        end
        # returns list of hashes:
        # [{"benchName"=>"Seq 0% Wallet",
        #   "restoreTime"=>466.7,
        #   "listAddressesTime"=>0.007535,
        #   "estimateFeesTime"=>1.166,
        #   "readWalletTime"=>1.166,
        #   "importOneAddressTime"=>1.166,
        #   "importManyAddressesTime"=>1.166,
        #   "utxoStatistics"=>"..."},
        #   {"benchName"=>"Seq 0% Wallet",
        #     ...
        #   }
        #   ...
        # ]
        x
      end

      module_function :read_to_hash
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

            if (l[0].include? LATENCY_CATEGORIES[0])
              h_top[LATENCY_CATEGORIES[0]] = h_main
              h_main = {}
            end

            if (l[0].include? LATENCY_CATEGORIES[1])
              h_top[LATENCY_CATEGORIES[1]] = h_main
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
