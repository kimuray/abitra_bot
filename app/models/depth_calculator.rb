class DepthCalculator
  attr_reader :bitflyer_depth, :cc_depth, :zaif_depth, :bitbank_depth

  def initialize
    @bitflyer_depth = DepthApi.new(target_url: 'https://api.bitflyer.jp/v1/board').request_bitflyer
    @cc_depth       = DepthApi.new(target_url: 'https://coincheck.com/api/order_books').request_depth_info
    @zaif_depth     = DepthApi.new(target_url: 'https://api.zaif.jp/api/1/depth/btc_jpy').request_depth_info
    @bitbank_depth  = DepthApi.new(target_url: 'https://public.bitbank.cc/btc_jpy/depth').request_depth_info['data']
  end

  def difference
    bids = {
      bitflyer: bitflyer_depth['bids'].first[0].to_f,
      coincheck: cc_depth['bids'].first[0].to_f,
      zaif: zaif_depth['bids'].first[0].to_f,
      bitbank: bitbank_depth['bids'].first[0].to_f
    }
    asks = {
      bitflyer: bitflyer_depth['asks'].first[0].to_f,
      coincheck: cc_depth['asks'].first[0].to_f,
      zaif: zaif_depth['asks'].first[0].to_f,
      bitbank: bitbank_depth['asks'].first[0].to_f
    }
    calc(bids, asks)
  end

  def calc(bids, asks)
    sort_bids = bids.sort_by { |_, v| -v }
    sort_asks = asks.sort_by { |_, v| v }
    bids_key, bids_value = sort_bids.shift
    asks_key, asks_value = sort_asks.shift
    return if asks_key == bids_key
    return if (bids_value - asks_value) < 5_000
    puts "#{asks_key}で#{asks_value}円買って、#{bids_key}で#{bids_value}円で売ると#{bids_value - asks_value}円お得っぽい"
  end

  def self.loop_execute
    loop do
      self.new.difference
      sleep 5
    end
  end
end