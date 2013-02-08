require 'amalgamate/unity'
require 'amalgamate/exceptions'

module Amalgamate
  extend ActiveSupport::Concern

  # Instance Methods
  def unify
    warn "TODO: Implement instance #unify method"
  end

  def diff
    warn "TODO: Implement instance #diff method"
  end

  # Class methods
  module ClassMethods
  end
end

ActiveRecord::Base.send(:include, Amalgamate)
