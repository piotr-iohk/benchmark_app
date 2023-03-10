Sequel.migration do
  change do
    add_column :mainnet_restores_new, :list_transactions_limited_time, Float
    add_column :testnet_restores_new, :list_transactions_limited_time, Float
	end
end
