class Message
  include ActiveModel::Model
  include Draper::Decoratable

  DELIVERED_STATUSES = %w(downloaded viewed).freeze
  ALL_EVENTS = [
    %w(video s3 uploaded),
    %w(video kvstore received),
    %w(video notification received),
    %w(video kvstore downloaded),
    %w(video notification downloaded),
    %w(video kvstore viewed),
    %w(video notification viewed)
  ].freeze

  attr_reader :file_name, :client_platform, :client_version
  alias_method :id, :file_name
  alias_method :to_s, :file_name
  delegate :viewed?, to: :status

  def self.all_s3_events(options = {})
    events = Event.s3_events
    events = events.with_sender(options.fetch(:sender_id)) if options.key?(:sender_id)
    events = events.with_receiver(options.fetch(:receiver_id)) if options.key?(:receiver_id)
    events = events.since(options.fetch(:start_date).to_date) if options.key?(:start_date)
    events = events.till(options.fetch(:end_date).to_date + 1) if options.key?(:end_date)
    events = events.page(options.fetch(:page, 1)) if options.key?(:page)
    events = events.page(1).per(options.fetch(:per, 100)) if options.key?(:per)
    order = options.fetch(:reverse, false) ? 'DESC' : 'ASC'
    events.order("triggered_at #{order}")
  end

  def self.build_from_s3_events(s3_events)
    events_cache = Event.with_video_filenames(s3_events.map(&:video_filename))
                        .order(:triggered_at)
                        .group_by(&:video_filename)
    s3_events.map do |s3_event|
      self.new s3_event, events: events_cache[s3_event.video_filename]
    end.uniq(&:id)
  end

  def self.all(options = {})
    build_from_s3_events(all_s3_events(options))
  end

  def self.build_from_events_scope(scope)
    events = scope.group("data->>'video_filename'",
                         :triggered_at, :name,
                         "data->>'sender_platform'",
                         "data->>'receiver_platform'",
                         "data->>'client_platform'",
                         "data->>'client_version'").count
    data = events.group_by { |row, _count| row.first }
    data.map do |file_name, row|
      next if file_name.nil?
      uploaded_at = row.map { |r| r[0][1] }.first
      event_names = row.map { |r| r[0][2] }
      sender_platform   = row.map { |r| r[0][3] }.compact.first.try(:to_sym) || :unknown
      receiver_platform = row.map { |r| r[0][4] }.compact.first.try(:to_sym) || :unknown
      client_platform   = row.map { |r| r[0][5] }.compact.first.try(:to_sym) || :undefined
      client_version    = row.map { |r| r[0][6] }.compact.first.try(:to_i)   || 0
      Message.new(file_name, event_names: event_names, uploaded_at: uploaded_at,
                  sender_platform: sender_platform, receiver_platform: receiver_platform,
                  client_platform: client_platform, client_version: client_version)
    end.compact
  end

  def initialize(file_name_or_event, options = {})
    if !file_name_or_event.is_a?(String) &&
      file_name_or_event.is_a?(Event) &&
      unless [%w(video s3 uploaded), %w(video sent)].include?(file_name_or_event.name)
        fail TypeError, 'value must be either file_name or video:s3:uploaded (video:sent) event'
      end
    end
    if file_name_or_event.is_a?(String)
      @file_name = file_name_or_event
    else
      @s3_event = file_name_or_event
      @file_name = @s3_event.video_filename
    end
    @event_names = options[:event_names]
    @events = options[:events]
    @sender_platform   = options[:sender_platform]
    @receiver_platform = options[:receiver_platform]
    @client_platform   = options[:client_platform]
    @client_version    = options[:client_version]
    @uploaded_at = options[:uploaded_at]
  end

  def ==(other)
    super || id == other.id
  end

  def inspect
    "#<#{self.class.name} #{file_name} (#{uploaded_at})>"
  end

  def s3_event
    @s3_event ||= find_s3_event
  end

  def events
    @events ||= Event.with_video_filename(file_name).order(:triggered_at)
  end

  def to_hash
    { id: id,
      sender_id: data.sender_id,
      receiver_id: data.receiver_id,
      uploaded_at: uploaded_at,
      file_name: file_name,
      file_size: file_size,
      missing_events: missing_events,
      status: status,
      delivered: delivered?,
      viewed: viewed?,
      complete: complete? }
  end
  alias_method :to_h, :to_hash

  def data
    @data ||= Hashie::Mash.new(s3_event.data)
  end

  def raw_params
    @raw_params ||= Hashie::Mash.new(s3_event.raw_params)
  end

  def uploaded_at
    @uploaded_at ||= s3_event.triggered_at
  end

  def file_size
    raw_params.s3.object['size']
  end

  def status
    @status ||= (ALL_EVENTS & event_names).last.last.inquiry
  end

  def delivered?
    DELIVERED_STATUSES.include?(status)
  end

  def undelivered?
    !delivered?
  end

  def event_names
    return @event_names if @event_names
    events.respond_to?(:pluck) ? events.pluck(:name) : events.map(&:name)
  end

  def missing_events
    ALL_EVENTS - event_names
  end

  def complete?
    missing_events.empty?
  end

  def incomplete?
    !complete?
  end

  def unviewed?
    !viewed?
  end

  def sender_platform
    @sender_platform ||= find_platform :sender
  end

  def receiver_platform
    @receiver_platform ||= find_platform :receiver
  end

  def sender_id
    @sender_id ||= file_name.split('-').first
  end

  def receiver_id
    @receiver_id ||= file_name.split('-').second
  end

  protected

  def find_s3_event
    s3_event = events.find { |e| [%w(video s3 uploaded), %w(video sent)].include?(e.name) }
    fail ActiveRecord::RecordNotFound, 'no video:s3:uploaded (video:sent) event found' if s3_event.blank?
    s3_event
  end

  def find_platform(member)
    e = events.find { |e| e.data["#{member}_platform"].present? }
    e && e.data["#{member}_platform"].to_sym || :unknown
  end
end
