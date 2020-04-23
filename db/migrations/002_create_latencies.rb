Sequel.migration do
  change do
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

    create_table :latency_benchmarks do
      primary_key :latency_benchmark_id
      String :name
    end
    # from(:latency_measurement_types).insert(type: "Latencies for 2 fixture wallets scenario")
    # from(:latency_measurement_types).insert(type: "Latencies for 10 fixture wallets scenario")
    # from(:latency_measurement_types).insert(type: "Latencies for 100 fixture wallets scenario")
    # from(:latency_measurement_types).insert(type: "Latencies for 2 fixture wallets with 10 txs scenario")
    # from(:latency_measurement_types).insert(type: "Latencies for 2 fixture wallets with 20 txs scenario")
    # from(:latency_measurement_types).insert(type: "Latencies for 2 fixture wallets with 100 txs scenario")
    # from(:latency_measurement_types).insert(type: "Latencies for 10 fixture wallets with 10 txs scenario")
    # from(:latency_measurement_types).insert(type: "Latencies for 10 fixture wallets with 20 txs scenario")
    # from(:latency_measurement_types).insert(type: "Latencies for 10 fixture wallets with 100 txs scenario")
    # from(:latency_measurement_types).insert(type: "Latencies for 2 fixture wallets with 100 utxos scenario")
    # from(:latency_measurement_types).insert(type: "Latencies for 2 fixture wallets with 200 utxos scenario")
    # from(:latency_measurement_types).insert(type: "Latencies for 2 fixture wallets with 500 utxos scenario")
    # from(:latency_measurement_types).insert(type: "Latencies for 2 fixture wallets with 1000 utxos scenario")

    create_table :latency_categories do
      primary_key :latency_category_id
      String :name
    end
    # from(:latency_wallet_types).insert(type: "Random wallets")
    # from(:latency_wallet_types).insert(type: "Icaurs wallets")
    # from(:latency_wallet_types).insert(type: "+++ Run benchmark - jormungandr")
	 end
end
