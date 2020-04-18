Sequel.migration do
  change do
    add_column :testnet_restores, :artifact_txt_url, String
    add_column :testnet_restores, :artifact_svg_url, String

    add_column :mainnet_restores, :artifact_txt_url, String
    add_column :mainnet_restores, :artifact_svg_url, String
    end
end
