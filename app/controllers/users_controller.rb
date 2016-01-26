class UsersController < ApplicationController
  before_action :set_user, only: [:show, :visualization, :events, :request_logs]
  decorates_assigned :user

  def index
    term = params[:user_id_or_mkey]
    if term.present?
      user = term =~ /^\d+$/i ? User.find(term.to_i) : User.find_by_mkey(term)
      if user.present?
        redirect_to(user)
      else
        flash[:alert] = t('messages.user_not_found', query: params[:user_id_or_mkey])
      end
    end
    @users = User.search(params[:query]).page(params[:page])
  end

  def show
    @message_statuses = if @user.connected_users.count > 1
      events_api.metric_data(:messages_statuses_between_users,
                             user_id: @user.event_id,
                             friend_ids: @user.connected_users.map(&:event_id))
                        else
                          {}
                        end
  end

  def events
    @user.events = events_api.filter_by(@user.event_id, reverse: true)
    @user.events.map! { |e| Event.new(e) }
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
