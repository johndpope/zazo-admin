class MetricsController < ApplicationController
  before_action :set_metric, only: [:show, :data]

  def index
    @metrics = Metric.to_render
  end

  def show
  end

  def options
    session[Metric::Options::SESSION_KEY] = Metric::Options.new(params[:id]).get_by_params(params)
    redirect_to request.referer
  end

  def data
    render json: @metric.data(params.except(:controller, :action, :id))
  end

  private

  def set_metric
    @metric = Metric.find_by_name params[:id]
  end
end
