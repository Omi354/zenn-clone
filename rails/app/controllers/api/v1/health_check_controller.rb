class Api::V1::HealthCheckController < Api::v1::BaseController
  def index
    render json: { message: "Success Health Check!" }, status: :ok
  end
end
