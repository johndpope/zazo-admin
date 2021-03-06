class UsersController < ApplicationController
  before_action :set_user, only: [:show, :connections, :events, :visualization, :request_logs]
  decorates_assigned :user

  def index
    term = params[:user_id_or_mkey]
    if term.present?
      user = term =~ /^\d+$/i ? User.find(term.to_i) : User.find_by_mkey(term)
      if user.present?
        redirect_to user
      else
        flash[:alert] = t 'messages.user_not_found', query: params[:user_id_or_mkey]
      end
    end
    @users = User.search(params[:query]).page(params[:page])
  end

  def show
  end

  def connections
    @message_statuses = @user.connected_users.count > 1 ?
      Metric.find_by_name(:messages_statuses_between_users).data({
        user_id: @user.mkey,
        friend_ids: @user.connected_users.pluck(:mkey)
      }) : {}
  end

  def events
  end

  def visualization
    allowed = UserVisualizationDataQuery::ALLOWED_SETTINGS
    @settings = allowed.each_with_object({}) { |attr, memo| memo[attr] = params[attr] }
  end

  def request_logs
    respond_to do |format|
      service = RequestLogNotification.new @user, params[:request_logs_options]
      if service.do
        format.html { redirect_to request_logs_user_path, notice: "Logs was successfully requested." }
      else
        format.html { redirect_to request_logs_user_path, alert: "Logs was not requested, errors: #{service.errors.messages}" }
      end
    end if request.post?
  end

  private

  def set_user
    @user = User.find params[:id]
  end
end
