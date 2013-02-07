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

    def unify(*args)
      options = args.extract_options!
      master, slave = args if args.any?
      master ||= @master
      slave ||= @slave
      priority = options[:priority] || :master
      secondary = priority.eql?(:master) ? :slave : :master
      diff_hash = self.diff(master, slave)
      merge_values = diff_hash.reduce({}) do |memo, attribute_set|
        attribute, values = attribute_set
        memo[attribute] = values[priority] || values[secondary]
        memo
      end
      master.assign_attributes(merge_values)
      master.save if options[:save] != false && master.changed?
      slave.destroy unless options[:destroy] == false
      master 
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