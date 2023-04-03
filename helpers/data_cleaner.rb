##
# helper module for dropping old data

module Helpers
  module DataCleaner
    def remove_this_and_older(db_conn, nb)
      nbs_to_remove = db_conn["SELECT * FROM nightly_builds WHERE build_no <= #{nb.to_i}"].all
      nbs_to_remove.each do |nb|
        remove_particular_nb(db_conn, nb)
      end
    end

    def remove_this_and_newer(db_conn, nb)
      nbs_to_remove = db_conn["SELECT * FROM nightly_builds WHERE build_no >= #{nb.to_i}"].all
      nbs_to_remove.each do |nb|
        remove_particular_nb(db_conn, nb)
      end
    end

    def remove(db_conn, nb)
      nb_to_remove = db_conn["SELECT * FROM nightly_builds WHERE build_no = #{nb.to_i}"].first
      remove_particular_nb(db_conn, nb_to_remove)
    end

    def remove_particular_nb(db_conn, nb)
      nb_id = nb[:nightly_build_id]
      puts "Removing: #{nb[:build_no]}"

      puts "  Latencies."
      puts db_conn[:latency_measurements].where(nightly_build_id: nb_id).delete

      puts "  Mainnet measuremenets."
      puts db_conn[:mainnet_restores_new].where(nightly_build_id: nb_id).delete

      puts "  Testnet measuremenets."
      puts db_conn[:testnet_restores_new].where(nightly_build_id: nb_id).delete

      puts "  API measuremenets."
      puts db_conn[:api_measurements].where(nightly_build_id: nb_id).delete

      puts "  Nightbuild itself."
      puts db_conn[:nightly_builds].where(nightly_build_id: nb_id).delete
    end

    module_function :remove, :remove_this_and_older, :remove_this_and_newer, :remove_particular_nb
  end
end
