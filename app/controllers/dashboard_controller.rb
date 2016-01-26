class DashboardController < ApplicationController
  def index
  end

  def users_created
    render json: User.send(:"group_by_#{@group_by}", :created_at).count
  end

  def users_device_platform
    render json: User.group(:device_platform).count
  end

  def users_status
    render json: User.group(:status).count
  end
end
