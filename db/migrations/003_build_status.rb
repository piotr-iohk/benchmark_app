Sequel.migration do
  change do
    add_column :nightly_builds, :build_status, String, default: "failed", null: false
	end
end
