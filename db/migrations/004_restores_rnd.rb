Sequel.migration do
  change do
    add_column :mainnet_restores, :time_rnd, Float
    add_column :testnet_restores, :time_rnd, Float
	end
end
