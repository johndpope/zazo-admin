class ConnectionsController < ApplicationController
  before_action :set_connection, only: [:show, :edit, :update, :destroy, :messages]
  decorates_assigned :creator_to_target_messages, :target_to_creator_messages

  def index
    @connections = Connection.all.page params[:page]
  end

  def show
    @aggregate_messaging_info = Metric::Data.get_data :aggregate_messaging_info,
                                                      user_id: @connection.creator.event_id,
                                                      friend_id: @connection.target.event_id
  end

  private

  def set_connection
    @connection = Connection.find(params[:id])
  end

  def connection_params
    params.require(:connection).permit(:creator_id, :target_id, :status)
  end
end
