Sequel.migration do
  change do
    create_table :mainnet_restores_new do
      primary_key :mainnet_restore_new_id
      foreign_key :nightly_build_id, :nightly_builds, :null => false
      String :bench_name
      Float :restoration_time
      Float :listing_addresses_time
      Float :estimating_fees_time
      String :utxo_statistics
    end

    create_table :testnet_restores_new do
      primary_key :testnet_restore_new_id
      foreign_key :nightly_build_id, :nightly_builds, :null => false
      String :bench_name
      Float :restoration_time
      Float :listing_addresses_time
      Float :estimating_fees_time
      String :utxo_statistics
    end
	 end
end
