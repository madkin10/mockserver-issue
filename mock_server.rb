require 'restclient'
require 'json'

module MockServer
  @protocol = 'http'
  @host = 'localhost'
  @port = 1080

  module_function

  def base_url
    "#{@protocol}://#{@host}:#{@port}"
  end

  def expectation_url
    "#{base_url}/expectation"
  end

  def register(expectation)
    RestClient.put(expectation_url, expectation)
  end

  def expectation(request_method, request_path, response_status, response_body)
    {
      httpRequest: {
        method: request_method,
        path: URI.encode(request_path)
      },
      httpResponse: {
        statusCode: response_status,
        headers: { 'Content-Type' => ['application/json; charset=utf-8'] },
        body: response_body
      }
    }.to_json
  end
end

expectation = MockServer.expectation('GET', '/foo', 200, [{foo: 'bar'}, {bar: 'foo'}])

begin
  puts "Sending Expectation: #{expectation}\n\n"

  MockServer.register expectation
rescue RestClient::ExceptionWithResponse => ex
  puts ex.response
end

