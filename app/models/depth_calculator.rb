class DepthCalculator
  attr_reader :bitflyer_depth, :cc_depth, :zaif_depth

  def initialize
    @bitflyer_depth = DepthApi.new(target_url: 'https://api.bitflyer.jp/v1/board').request_bitflyer
    @cc_depth       = DepthApi.new(target_url: 'https://coincheck.com/api/order_books').request_depth_info
    @zaif_depth     = DepthApi.new(target_url: 'https://api.zaif.jp/api/1/depth/btc_jpy').request_depth_info
  end

  def difference
    bids = {
      bitflyer: bitflyer_depth['bids'].first[0].to_f,
      coincheck: cc_depth['bids'].first[0].to_f,
      zaif: zaif_depth['bids'].first[0].to_f
    }
    asks = {
      bitflyer: bitflyer_depth['asks'].first[0].to_f,
      coincheck: cc_depth['asks'].first[0].to_f,
      zaif: zaif_depth['asks'].first[0].to_f
    }
    calc(bids, asks)
  end

  def calc(bids, asks)
    sort_bids = bids.sort_by { |_, v| v }
    sort_asks = asks.sort_by { |_, v| -v }
    bids_key, bids_value = sort_bids.shift
    asks_key, asks_value = sort_asks.shift
    puts "#{asks_key}で#{asks_value}円買って、#{bids_key}で#{bids_value}円で売ると#{asks_value - bids_value}円お得っぽい"
  end
end