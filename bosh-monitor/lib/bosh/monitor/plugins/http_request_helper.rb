require 'httpclient'

module Bosh::Monitor::Plugins
  module HttpRequestHelper
    def send_http_put_request(uri, request)
      logger.debug("sending HTTP PUT to: #{uri}")

      name = self.class.name
      started = Time.now
      http = EM::HttpRequest.new(uri).send(:put, request)
      http.callback do
        logger.debug("#{name} event sent (took #{Time.now - started} seconds): #{http.response_header.status}")
      end

      http.errback do |e|
        logger.error("Failed to send #{name} event: #{e.error}")
      end
    end

    def send_http_get_request(uri)
      # we are interested in response, so send sync request
      logger.debug("Sending GET request to #{uri}")
      sync_client(OpenSSL::SSL::VERIFY_NONE).get(uri)
    end

    def send_http_post_sync_request(uri, request)
      cli = sync_client
      cli.proxy = request[:proxy] if request[:proxy]
      cli.post(uri, request[:body])
    end

    private

    def sync_client(ssl_verify_mode = OpenSSL::SSL::VERIFY_PEER)
      client = HTTPClient.new
      client.ssl_config.verify_mode = ssl_verify_mode
      client
    end
  end
end
