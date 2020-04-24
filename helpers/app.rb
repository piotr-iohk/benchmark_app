module Helpers
  module App
    def link_to_nb id
      "<a href='/nightbuilds/#{id.to_s}'>#{id.to_s}</a>"
    end

    def latency_graphs_per_benchmark_data(b)
      [{ :name => "listWallets", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:listWallets]]}.to_h},
       { :name => "getWallet", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:getWallet]]}.to_h},
       { :name => "getUTxOsStatistics", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:getUTxOsStatistics]]}.to_h},
       { :name => "listAddresses", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:listAddresses]]}.to_h},
       { :name => "listTransactions", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:listTransactions]]}.to_h},
       { :name => "postTransactionFee", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:postTransactionFee]]}.to_h},
       { :name => "getNetworkInfo", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:getNetworkInfo]]}.to_h}]
    end
  end
end
