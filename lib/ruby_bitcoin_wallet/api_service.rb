require 'net/https'
require 'uri'
require 'json'

module ApiService

  BASE_URI = "https://blockchain.info/address/"

  def self.address_balance_and_transactions(address)
    uri = api_parsed_uri(address)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    begin
      JSON.parse(response.body)
    rescue JSON::ParserError => e
      "No data registered for address #{address}"
    end
  end

  def self.api_parsed_uri(address)
    URI.parse(BASE_URI + address + "?format=json")
  end

end