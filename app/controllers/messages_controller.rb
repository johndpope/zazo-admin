class MessagesController < AdminController
  def index
    raw = events_api.messages(messages_params)
    @sender = User.find_by_mkey(messages_params[:sender_id])
    @receiver = User.find_by_mkey(messages_params[:receiver_id])
    @messages = raw.map { |m| Message.new(m) }
    @filter = params[:filter]
    if @filter && Message.new.respond_to?(:"#{@filter}?")
      @messages.select!(&:"#{@filter}?")
    end
    @messages = MessageDecorator.decorate_collection(@messages)
  end

  def show
    message_id = params[:id]
    raw = events_api.message(message_id)
    @message = Message.new(raw).decorate
  rescue Faraday::ResourceNotFound
    head :not_found
  end

  def duplications
    @metric = Metric.new name: 'upload_duplications_data', type: 'upload_duplications_data'
  end

  private

  def messages_params
    params.permit(:sender_id, :receiver_id, :reverse, :page, :per, :filter)
  end
end
