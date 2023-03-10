module Helpers
  module App
    GH_URL = "https://github.com/input-output-hk/cardano-wallet/commit"
    BK_URL = "https://buildkite.com/input-output-hk/cardano-wallet-nightly/builds"

    def build_status(status, build_no)
      case status
      when "failed" then cl = "bg-danger"
      when "canceled" then cl = "bg-warning"
      when "passed" then cl = "bg-success"
      else cl = "bg-warning"
      end
      "<a href='#{BK_URL}/#{build_no}' class='d-inline p-2 #{cl} text-white' target='_blank'>#{status}</a>"
    end

    def link_to_nb id
      "<a href='/nightbuilds/#{id.to_s}'>#{id.to_s}</a>"
    end

    def nighbuild_results_table(res)
      table = %Q{
        <table class="table table-hover">
        <thead>
          <tr>
            <th scope="col">Bench name</th>
            <th scope="col">Restore time</th>
            <th scope="col">List addresses</th>
            <th scope="col">Estimate fees</th>
            <th scope="col">Read wallet</th>
            <th scope="col">List txs</th>
            <th scope="col">List txs (max_count = 100)</th>
            <th scope="col">Import one address</th>
            <th scope="col">Import many addresses</th>
          </tr>
        </thead>
        <tbody>
      }
      res.each do |m|
        table += %Q{
            <tr>
              <td scope="row">
                <details>
                  <summary>#{m[:bench_name]}</summary>
                    <code>

                    #{m[:utxo_statistics] ? m[:utxo_statistics].gsub("...", "<br/>&nbsp;...").
                                          gsub("number_of_t", "<br/>number_of_t").
                                          gsub("= T", "<br/>= T") : "<i>N/A</i>"}
                    </code>
                </details>
              </td>
              <td>
                #{m[:restoration_time] ? "#{m[:restoration_time]} s" : "<i>N/A</i>"}
              </td>
              <td>
                #{m[:listing_addresses_time] ? "#{m[:listing_addresses_time]} s" : "<i>N/A</i>"}
              </td>
              <td>
                #{m[:estimating_fees_time] ? "#{m[:estimating_fees_time]} s" : "<i>N/A</i>"}
              </td>
              <td>
                #{m[:read_wallet_time] ? "#{m[:read_wallet_time]} s" : "<i>N/A</i>"}
              </td>
              <td>
                #{m[:list_transactions_time] ? "#{m[:list_transactions_time]} s" : "<i>N/A</i>"}
              </td>
              <td>
              #{m[:list_transactions_limited_time] ? "#{m[:list_transactions_limited_time]} s" : "<i>N/A</i>"}
            </td>
              <td>
                #{m[:import_one_address_time] ? "#{m[:import_one_address_time]} s" : "<i>N/A</i>"}
              </td>
              <td>
                #{m[:import_many_addresses_time] ? "#{m[:import_many_addresses_time]} s" : "<i>N/A</i>"}
              </td>
            </tr>
          }
      end
      table += %Q{
          </tbody>
        </table>
      }
      table
    end

    def restoration_dataset(dataset, filter = [])
      data = [{ :name => "restoration_time", :data => dataset.map{|i| [link_to_nb(i[:build_no]), i[:restoration_time]]}.to_h},
       { :name => "listing_addresses_time", :data => dataset.map{|i| [link_to_nb(i[:build_no]), i[:listing_addresses_time]]}.to_h},
       { :name => "estimating_fees_time", :data => dataset.map{|i| [link_to_nb(i[:build_no]), i[:estimating_fees_time]]}.to_h},
       { :name => "read_wallet_time", :data => dataset.map{|i| [link_to_nb(i[:build_no]), i[:read_wallet_time]]}.to_h},
       { :name => "list_transactions_time", :data => dataset.map{|i| [link_to_nb(i[:build_no]), i[:list_transactions_time]]}.to_h},
       { :name => "list_transactions_limited_time", :data => dataset.map{|i| [link_to_nb(i[:build_no]), i[:list_transactions_limited_time]]}.to_h},
       { :name => "import_one_address_time", :data => dataset.map{|i| [link_to_nb(i[:build_no]), i[:import_one_address_time]]}.to_h},
       { :name => "import_many_addresses_time", :data => dataset.map{|i| [link_to_nb(i[:build_no]), i[:import_many_addresses_time]]}.to_h}
      ]
      if filter.empty?
        data
      elsif filter.include? "all"
        data
      else
        d = data.select { |s| s if filter.include? s[:name] }
        d.empty? ? data : d
      end
    end

    def restoration_graph(dataset, bench, url, filter = [])
      line_chart restoration_dataset(dataset.where(bench_name: bench), filter),
          title: "<a href='#'>#{bench} #{((url.include? "mainnet") ? "mainnet" : "testnet")}</a>",
          ytitle: "Time (s)", xtitle: "Nightbuild no"
    end

    def latency_graphs_per_benchmark_data(b, filter = [])
      data = [{ :name => "listWallets", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:listWallets]]}.to_h},
       { :name => "getWallet", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:getWallet]]}.to_h},
       { :name => "getUTxOsStatistics", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:getUTxOsStatistics]]}.to_h},
       { :name => "listAddresses", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:listAddresses]]}.to_h},
       { :name => "listTransactions", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:listTransactions]]}.to_h},
       { :name => "getTransaction", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:getTransaction]]}.to_h},
       { :name => "postTransactionFee", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:postTransactionFee]]}.to_h},
       { :name => "postTransaction", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:postTransaction]]}.to_h},
       { :name => "postTransactionMA", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:postTransactionMA]]}.to_h},
       { :name => "postTransTo5Addrs", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:postTransTo5Addrs]]}.to_h},
       { :name => "getNetworkInfo", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:getNetworkInfo]]}.to_h},
       { :name => "listStakePools", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:listStakePools]]}.to_h},
       { :name => "listMultiAssets", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:listMultiAssets]]}.to_h},
       { :name => "getMultiAsset", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:getMultiAsset]]}.to_h},
       { :name => "postMigrationPlan", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:postMigrationPlan]]}.to_h},
       { :name => "postMigration", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:postMigration]]}.to_h}
       ]
      if filter.empty?
        data
      elsif filter.include? "all"
        data
      else
        d = data.select { |s| s if filter.include? s[:name] }
        d.empty? ? data : d
      end
    end

    def latency_graphs_per_benchmark_render(category_name, latencies, dataset, data_filter = [])
      charts = ""
      latencies = latencies.order(Sequel.desc(:latency_benchmark_id))
      latencies.each do | benchmark |
        b = dataset.all.
            select{|i| i if (i[:category] == category_name) &&
            i[:benchmark] == benchmark[:name] }
        data = latency_graphs_per_benchmark_data b, data_filter


       charts += line_chart data,
          title: benchmark[:name],
          ytitle: "Time (ms)", xtitle: "Nightbuild no"

       charts += "<br/>"
      end
      charts
    end
  end
end
