module EventModelPatch
  def self.included(base)
    base.extend ClassMethods
    base.include InstanceMethods

    base.class_eval do
      paginates_per 100
    end
  end

  module ClassMethods
  end

  module InstanceMethods
  end
end

Event.include EventModelPatch
