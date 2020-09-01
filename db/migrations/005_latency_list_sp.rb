Sequel.migration do
  change do
    add_column :latency_measurements, :listStakePools, Float
	end
end
