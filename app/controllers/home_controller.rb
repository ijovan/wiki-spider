class HomeController < ApplicationController
  protect_from_forgery
  skip_before_action :verify_authenticity_token, if: :json_request?

  def create
    payload = JSON.parse(request.body.read)

    fork do
      SearchHandler.find_by_url(payload["startNode"], payload["endNode"], payload["channel"])
    end

    render json: {}, status: 200
  end

  def json_request?
    request.format.json?
  end
end
