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

    def unify(master=@master, slave=@slave, options={})
      diff_hash = self.diff(master, slave)
      merge_values = diff_hash.reduce({}) do |memo, attribute_set|
        attribute, values = attribute_set
        memo[attribute] = values[:master] || values[:slave]
        memo
      end
      master.assign_attributes(merge_values)
      master.save if master.changed?
      slave.destroy  
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