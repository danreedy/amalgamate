module Amalgamate
  extend ActiveSupport::Concern

  # Instance Methods
  included do
    def unify(slave, options={})
      unity = Amalgamate::Unity.new(self, slave)
      unity.unify(options)
    end

    def diff(slave, options={})
      unity = Amalgamate::Unity.new(self, slave)
      unity.diff(options)  
    end
  end

  # Class methods
  module ClassMethods
    def can_be_merged?; true end
  end
end

ActiveRecord::Base.send(:include, Amalgamate)