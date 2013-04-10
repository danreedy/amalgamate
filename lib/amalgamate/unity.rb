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
        memo[attribute] = values[priority].nil? ? values[secondary] : values[priority]
        memo
      end
      master.assign_attributes(merge_values, without_protection: true)
      master.save if options[:save] != false && master.changed?
      self.reassign_associations(master, slave, priority: priority) unless options[:reassign_associations] == false
      slave.destroy unless options[:destroy] == false
      master 
    end

    def diff(*args)
      options = args.extract_options!
      master, slave = args if args.any?
      master ||= @master
      slave ||= @slave
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

    def reassign_associations(*args)
      options = args.extract_options!
      master, slave = args
      master ||= @master
      slave  ||= @slave
      master.reflections.each_pair do |reflection, details|
        if details.macro == :has_many && !details.options.has_key?(:through)
          slave.send(reflection).update_all(details.foreign_key.to_sym => master.id) unless slave.send(reflection).nil?
        end
      end
    end

  end
end
