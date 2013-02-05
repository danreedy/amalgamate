module Amalgamate
  class Unity
    IGNORED_ATTRIBUTES = [
      :id,
      :created_at,
      :updated_at
    ]
    attr_accessor :master, :slave
    def initialize(*args)
      @master, @slave = args
      raise ClassMismatchError unless @master.class.eql?(@slave.class) 
    end

    def unify(master, slave, options={})
      
    end

    def combine(master, slave, options={})
      
    end

    def diff(master=@master, slave=@slave, options={})
      options[:ignore] ||= IGNORED_ATTRIBUTES 
      master.attributes.keys.inject({}) do |memo, attribute|
        attribute = attribute.to_sym
        unless options[:ignore].include?(attribute)
          memo[attribute] = { master: master.send(attribute), slave: slave.send(attribute) } unless master.send(attribute).eql?(slave.send(attribute))
        end
        memo
      end
    end

    def differing_attributes(master=@master, slave=@slave, options={})
      self.diff(master,slave).keys
    end
  end
end