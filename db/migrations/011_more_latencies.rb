Sequel.migration do
  change do
    add_column :latency_measurements, :getTransaction, Float
    add_column :latency_measurements, :postTransactionMA, Float
    add_column :latency_measurements, :listMultiAssets, Float
    add_column :latency_measurements, :getMultiAsset, Float
	end
end
