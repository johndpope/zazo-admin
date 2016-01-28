module UserFactoryMethods
  def mobile_number=(value)
    super GlobalPhone.normalize(value)
  end
end

User.send :include, UserFactoryMethods
