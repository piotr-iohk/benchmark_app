Sequel.migration do
  change do
    alter_table :testnet_restores do
      drop_column :artifact_txt_url
      drop_column :artifact_svg_url
    end

    alter_table :mainnet_restores do
      drop_column :artifact_txt_url
      drop_column :artifact_svg_url
    end
  end
end
