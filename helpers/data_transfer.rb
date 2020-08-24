##
# helper module for puting serialized data from buildkite into DB
module Helpers
  module DataTransfer
    def insert_into_db(buildkite_data_hash, db_connection, options = {})
      res = buildkite_data_hash
      if res[:build]
        build_no = res[:build][:build_no]
        build_status = res[:build][:build_status]
        datetime = res[:build][:datetime]
        rev = res[:build][:rev]
        nb = db_connection[:nightly_builds].where(build_no: build_no).first
        if nb
          puts " Using build #{build_no}..."
          nightly_build_id = nb[:nightly_build_id]
        else
          puts " Inserting new build..."
          nightly_build_id = db_connection[:nightly_builds].insert(datetime: datetime,
            build_no: build_no,
            rev: rev,
            build_status: build_status)
        end
      end

      if options[:skip_mainnet]
        puts "Skipping mainnet_restores..."
      else
        if res[:mainnet_restores]
          m = res[:mainnet_restores]
          puts " Inserting mainnet_restores for build: #{build_no}"
          db_connection[:mainnet_restores].insert(nightly_build_id: nightly_build_id,
            time_seq: m[:time_seq],
            time_rnd: m[:time_rnd],
            time_1per: m[:time_1per],
            time_2per: m[:time_2per])
        end
      end

      if options[:skip_testnet]
        puts "Skipping testnet_restores..."
      else
        if res[:testnet_restores]
          t = res[:testnet_restores]
          puts " Inserting testnet_restores for build: #{build_no}"
          db_connection[:testnet_restores].insert(nightly_build_id: nightly_build_id,
                                       time_seq: t[:time_seq],
                                       time_rnd: t[:time_rnd],
                                       time_1per: t[:time_1per],
                                       time_2per: t[:time_2per])
        end
      end

      if options[:skip_latency]
        puts "Skipping latency..."
      else
        if res[:latency_results]
          res[:latency_results].each_pair do |latency_category, latency_benchmarks|
            # insert latency_wallet_type if exists or use existing
            l_wal_type = db_connection[:latency_categories].
            select(:latency_category_id).
            where(name: latency_category).first

            if l_wal_type
              puts " Using existing #{latency_category}..."
              latency_category_id = l_wal_type[:latency_category_id]
            else
              puts " Inserting new #{latency_category}..."
              latency_category_id = db_connection[:latency_categories].
              insert(name: latency_category)
            end

            latency_benchmarks.each_pair do |latency_benchmark, m|
              # insert latency_benchmark if exists or use existing
              l_meas_type = db_connection[:latency_benchmarks].
              select(:latency_benchmark_id).
              where(name: latency_benchmark).first
              if l_meas_type
                puts "  Using exisitng #{latency_benchmark}..."
                latency_benchmark_id = l_meas_type[:latency_benchmark_id]
              else
                puts "  Inserting new #{latency_benchmark}..."
                latency_benchmark_id = db_connection[:latency_benchmarks].
                insert(name: latency_benchmark)
              end

              puts "    Inserting measurements..."
              db_connection[:latency_measurements].
              insert(nightly_build_id: nightly_build_id,
                latency_category_id: latency_category_id,
                latency_benchmark_id: latency_benchmark_id,
                listWallets: m['listWallets'],
                getWallet: m['getWallet'],
                getUTxOsStatistics: m['getUTxOsStatistics'],
                listAddresses: m['listAddresses'],
                listTransactions: m['listTransactions'],
                postTransactionFee: m['postTransactionFee'],
                getNetworkInfo: m['getNetworkInfo'] )
            end
          end
        else
          puts "No results for latency..."
        end
      end
    end #insert_into_db

    def find_builds_to_transfer(current_id, list_of_last_ids)
      list_to_return = []
        list_of_last_ids.each do |id|
          return list_to_return if current_id == id
          list_to_return << id
        end
    end

    module_function :insert_into_db, :find_builds_to_transfer

  end
end
