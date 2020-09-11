Sequel.migration do
  change do
    self[:mainnet_restores_new].where(bench_name: "Seq 0% Wallet").update(bench_name: "0-percent-seq")
    self[:mainnet_restores_new].where(bench_name: "Seq 0.1% Wallet").update(bench_name: "0.1-percent-seq")
    self[:mainnet_restores_new].where(bench_name: "Seq 0.2% Wallet").update(bench_name: "0.2-percent-seq")
    self[:mainnet_restores_new].where(bench_name: "Seq 0.4% Wallet").update(bench_name: "0.4-percent-seq")
    self[:mainnet_restores_new].where(bench_name: "Rnd 0% Wallet").update(bench_name: "0-percent-rnd")
    self[:mainnet_restores_new].where(bench_name: "Rnd 0.1% Wallet").update(bench_name: "0.1-percent-rnd")
    self[:mainnet_restores_new].where(bench_name: "Rnd 0.2% Wallet").update(bench_name: "0.2-percent-rnd")
    self[:mainnet_restores_new].where(bench_name: "Rnd 0.4% Wallet").update(bench_name: "0.4-percent-rnd")

    self[:testnet_restores_new].where(bench_name: "Seq 0% Wallet").update(bench_name: "0-percent-seq")
    self[:testnet_restores_new].where(bench_name: "Seq 0.1% Wallet").update(bench_name: "0.1-percent-seq")
    self[:testnet_restores_new].where(bench_name: "Seq 0.2% Wallet").update(bench_name: "0.2-percent-seq")
    self[:testnet_restores_new].where(bench_name: "Seq 0.4% Wallet").update(bench_name: "0.4-percent-seq")
    self[:testnet_restores_new].where(bench_name: "Rnd 0% Wallet").update(bench_name: "0-percent-rnd")
    self[:testnet_restores_new].where(bench_name: "Rnd 0.1% Wallet").update(bench_name: "0.1-percent-rnd")
    self[:testnet_restores_new].where(bench_name: "Rnd 0.2% Wallet").update(bench_name: "0.2-percent-rnd")
    self[:testnet_restores_new].where(bench_name: "Rnd 0.4% Wallet").update(bench_name: "0.4-percent-rnd")

    add_column :mainnet_restores_new, :read_wallet_time, Float
    add_column :mainnet_restores_new, :list_transactions_time, Float
    add_column :mainnet_restores_new, :import_one_address_time, Float
    add_column :mainnet_restores_new, :import_many_addresses_time, Float

    add_column :testnet_restores_new, :read_wallet_time, Float
    add_column :testnet_restores_new, :list_transactions_time, Float
    add_column :testnet_restores_new, :import_one_address_time, Float
    add_column :testnet_restores_new, :import_many_addresses_time, Float
  end
end
