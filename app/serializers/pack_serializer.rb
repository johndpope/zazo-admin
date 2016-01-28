class PackSerializer
  ATTRIBUTES = []

  def initialize(collection, options)
    @collection = collection
    @options    = options
  end

  def serialize
    @collection.map { |m| serialize_member m }
  end

  protected

  def serialize_member(member)
    self.class::ATTRIBUTES.each_with_object({}) do |attr, memo|
      memo[attr] = respond_to?("member_#{attr}", true) ?
        send("member_#{attr}", member) : member.send(attr)
    end
  end
end
