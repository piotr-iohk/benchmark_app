module Helpers
  module App
    def link_to_nb id
      "<a href='/nightbuilds/#{id.to_s}'>#{id.to_s}</a>"
    end

    def latency_graphs_per_benchmark_data(b, filter = [])
      data = [{ :name => "listWallets", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:listWallets]]}.to_h},
       { :name => "getWallet", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:getWallet]]}.to_h},
       { :name => "getUTxOsStatistics", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:getUTxOsStatistics]]}.to_h},
       { :name => "listAddresses", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:listAddresses]]}.to_h},
       { :name => "listTransactions", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:listTransactions]]}.to_h},
       { :name => "postTransactionFee", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:postTransactionFee]]}.to_h},
       { :name => "getNetworkInfo", :data => b.map{|i| [link_to_nb(i[:build_no]), i[:getNetworkInfo]]}.to_h}]
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
