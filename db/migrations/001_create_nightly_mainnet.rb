Sequel.migration do
  change do
    create_table :nightly_builds do
      primary_key :nightly_build_id
      DateTime :datetime, :null => false
      Integer :build_no, :null => false
      String :rev, :length => 40, :null => false
    end
    create_table :mainnet_restores do
      primary_key :mainnet_restore_id
      foreign_key :nightly_build_id, :nightly_builds, :null => false
      Float :time_seq
      Float :time_1per
      Float :time_2per
    end
    create_table :testnet_restores do
      primary_key :testnet_restore_id
      foreign_key :nightly_build_id, :nightly_builds, :null => false
      Float :time_seq
      Float :time_1per
      Float :time_2per
    end
	 end
end
