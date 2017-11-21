class DepthApi
  attr_reader :target_url

  def initialize(target_url: nil)
    @target_url = target_url
  end

  def request_depth_info
    response = Net::HTTP.get_response(URI.parse(target_url))
    transrate_json(response)
  end

  def transrate_json(response)
    begin
      case response
      when Net::HTTPSuccess
        result = JSON.parse(response.body)
      when Net::HTTPRedirection
        Rails.logger.info("Redirection: code=#{response.code} message=#{response.message}")
      else
        Rails.logger.info("HTTP ERROR: code=#{response.code} message=#{response.message}")
      end
      return result
    rescue IOError => e
      Rails.logger.error(e.message)
      raise(e)
    rescue TimeoutError => e
      Rails.logger.error(e.message)
      raise(e)
    rescue JSON::ParserError => e
      Rails.logger.error(e.message)
      raise(e)
    rescue => e
      Rails.logger.error(e.message)
      railse(e)
    end
  end

  def request_bitflyer
    result = {}
    depth_json = request_depth_info
    result.store('bids', depth_json['bids'].map { |item| [item['price'], item['size']] })
    result.store('asks', depth_json['asks'].map { |item| [item['price'], item['size']] })
    result
  end
end