class ProxyController < ApplicationController
  def index
    url = URI.parse(params["url"])
    result = Net::HTTP.get_response(url)
    send_data result.body, :type => result.content_type, :disposition => 'inline'
  end
end