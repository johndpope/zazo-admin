module KvstoreFactoryMethods
  def create_or_update(params)
    if params[:key2].blank?
      kvs = where('key1 = ? and key2 is null', params[:key1])
    else
      kvs = where('key1 = ? and key2 = ?', params[:key1], params[:key2])
    end

    if kvs.present?
      kvs.first.update_attribute(:value, params[:value])
    else
      create(key1: params[:key1], key2: params[:key2], value: params[:value])
    end
  end

  def digest(string)
    Digest::MD5.new.update(string).hexdigest
  end

  def generate_id_key(sender, receiver, connection)
    "#{sender.mkey}-#{receiver.mkey}-#{connection.ckey}-VideoIdKVKey"
  end

  def generate_status_key(sender, receiver, connection)
    "#{sender.mkey}-#{receiver.mkey}-#{digest(sender.mkey + receiver.mkey + connection.ckey)}-VideoStatusKVKey"
  end

  def add_id_key(sender, receiver, video_id)
    connection = Connection.live_between(sender.id, receiver.id).first
    fail 'no live connections found' if connection.nil?
    params = {}
    params[:key1] = generate_id_key(sender, receiver, connection)
    params[:key2] = video_id
    params[:value] = { 'videoId' => video_id }.to_json
    Kvstore.create_or_update(params)
  end

  def add_status_key(sender, receiver, video_id, status)
    connection = Connection.live_between(sender.id, receiver.id).first
    fail 'no live connections found' if connection.nil?
    params = {}
    params[:key1] = generate_status_key(sender, receiver, connection)
    params[:value] = { 'videoId' => video_id, status: status }.to_json
    Kvstore.create_or_update(params)
  end

  def video_filename(sender, receiver, video_id)
    sender = User.find_by(mkey: sender) if sender.is_a?(String)
    receiver = User.find_by(mkey: receiver) if receiver.is_a?(String)
    connection = Connection.live_between(sender.id, receiver.id).first
    fail "No connection found between #{sender.name} and #{receiver.name}" if connection.nil?
    "#{sender.mkey}-#{receiver.mkey}-#{digest(connection.ckey + video_id)}"
  end
end

Kvstore.send :extend, KvstoreFactoryMethods
