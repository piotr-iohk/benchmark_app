Sequel.migration do
  change do
    create_table :latency_categories do
      primary_key :latency_category_id
      String :name
    end

    create_table :latency_benchmarks do
      primary_key :latency_benchmark_id
      String :name
    end

    create_table :latency_measurements do
      primary_key :latency_measurement_id
      foreign_key :nightly_build_id, :nightly_builds, :null => false
      foreign_key :latency_benchmark_id, :latency_benchmarks, :null => false
      foreign_key :latency_category_id, :latency_categories, :null => false
      Float :listWallets
      Float :getWallet
      Float :getUTxOsStatistics
      Float :listAddresses
      Float :listTransactions
      Float :postTransactionFee
      Float :getNetworkInfo
    end
	end
end
