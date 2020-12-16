Sequel.migration do
  change do
    add_column :latency_measurements, :postTransaction, Float
    add_column :latency_measurements, :postTransTo5Addrs, Float
	end
end
