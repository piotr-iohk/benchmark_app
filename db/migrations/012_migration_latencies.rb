Sequel.migration do
  change do
    add_column :latency_measurements, :postMigrationPlan, Float
    add_column :latency_measurements, :postMigration, Float
	end
end
