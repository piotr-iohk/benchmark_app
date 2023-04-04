Sequel.migration do
  change do
    drop_table :testnet_restores_new
  end
end
