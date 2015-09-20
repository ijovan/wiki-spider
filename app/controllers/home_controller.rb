class HomeController < ApplicationController
  protect_from_forgery
  skip_before_action :verify_authenticity_token, if: :json_request?

  def index
  end

  def create
    payload = JSON.parse request.body.read

    Reader.find_by_url(payload["startNode"], payload["endNode"])

    render json: {}, status: 200
  end

  def json_request?
    request.format.json?
  end
end
