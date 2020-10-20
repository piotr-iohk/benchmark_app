Sequel.migration do
  change do
    self[:latency_benchmarks].where(name: "Latencies for 100 fixture wallets scenario").
                              update(name: "Latencies for 100 fixture wallets")

  end
end
