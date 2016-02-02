class MetricsController < ApplicationController
  def index
    @metrics = Settings.allowed_metrics
  end

  def show
    @metric = params[:id]
  end

  def options
    session[Metric::Options::SESSION_KEY] = Metric::Options.new(params[:id]).get_by_params(params)
    redirect_to request.referer
  end

  def data
    render json: Metric::Data.get_data(params[:id])
  end
end
