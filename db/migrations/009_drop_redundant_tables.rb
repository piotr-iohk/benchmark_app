Sequel.migration do
  change do
    drop_table :mainnet_restores
    drop_table :testnet_restores
  end
end
