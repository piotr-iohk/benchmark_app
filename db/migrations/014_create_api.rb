Sequel.migration do
  change do
    create_table :api_measurements do
      primary_key :api_measurement_id
      foreign_key :nightly_build_id, :nightly_builds, :null => false
      String :bench_name
      String :utxo_statistics
      Float :readWalletTime
      Float :getWalletUtxoSnapshotTime
      Float :listAddressesTime
      Float :listAssetsTime
      Float :listTransactionsTime
      Float :listTransactionsLimitedTime
      Float :createMigrationPlanTime
      Float :delegationFeeTime
      Float :selectAssetsTime
    end
	end
end
