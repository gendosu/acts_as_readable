module ActsAsReadable
  module ActMethod  
    # OPTIONS
    # :cache  => the name under which to cache timestamps for a "mark all as read" action to avoid the need to actually create readings for each record marked as read
    def acts_as_readable(options = {})
      class_attribute :acts_as_readable_options
      self.acts_as_readable_options = options

      has_many :readings, :as => :readable
      has_many :readers, :through => :readings, :source => :user, :conditions => {:readings => {:state => 'read'}}

      scope :read_by, lambda {|user| ActsAsReadable::HelperMethods.outer_join_readings(self).where(ActsAsReadable::HelperMethods.read_conditions(self, user))}
      scope :unread_by, lambda {|user| ActsAsReadable::HelperMethods.outer_join_readings(self).where(ActsAsReadable::HelperMethods.unread_conditions(self, user))}

      extend ActsAsReadable::ClassMethods
      include ActsAsReadable::InstanceMethods
    end
  end
  
  module HelperMethods
    def self.read_conditions(readable_class, user)
      ["(readable_type IS NULL AND COALESCE(#{readable_class.table_name}.updated_at < ?, TRUE)) OR (readable_type IS NOT NULL AND COALESCE(readings.updated_at < ?, TRUE)) OR (readings.state = 'read')", all_read_at(readable_class, user), all_read_at(readable_class, user)]
    end
    
    def self.unread_conditions(readable_class, user)
      ["(readable_type IS NULL AND COALESCE(#{readable_class.table_name}.updated_at > ?, TRUE)) OR (readings.state = 'unread' AND COALESCE(readings.updated_at > ?, TRUE))", all_read_at(readable_class, user), all_read_at(readable_class, user)]
    end
    
    def self.all_read_at(readable_class, user)
      user[readable_class.acts_as_readable_options[:cache]]
    end

    def self.outer_join_readings(readable_class)
      Reading.joins("LEFT OUTER JOIN readings ON readable_type = '#{readable_class.name}' AND readable_id = #{readable_class.table_name}.id")
    end        
  end

  module ClassMethods
    # Find all the readings of the readables by the user in a single SQL query and cache them in the readables for use in the view.
    def cache_readings_for(readables, user)
      readings = []
      Reading.where(:readable_type => name, :readable_id => readables.collect(&:id), :user_id => user.id).each do |reading|
        readings[reading.readable_id] = reading
      end

      for readable in readables
        readable.cached_reading = readings[readable.id] || false
      end
      
      return readables
    end
    
    # Mark all records as read by the user
    # If a :cache option has been set in acts_as_readable, a timestamp will be updated on the user instead of creating individual readings for each record
    def read_by!(user)
      if acts_as_readable_options[:cache] && user.respond_to?("#{acts_as_readable_options[:cache]}=")
        Reading.delete_all(:user_id => user.id, :readable_type => name)
        user[acts_as_readable_options[:cache]] = Time.now
        user.save!
      else
        unread_by(user).find_each do |record|
          record.read_by!(user)
        end
      end
    end
  end

  module InstanceMethods
    attr_accessor :cached_reading

    def acts_like_readable?
      true
    end

    def read_by!(user)
      # Find an existing reading and update the record so we can know when the thing was first read, and the last time we read it
      reading = Reading.find_or_initialize_by_user_id_and_readable_id_and_readable_type(:user_id => user.id, :readable_id => self.id, :readable_type => self.class.name)
      reading.updated_at = Time.now
      reading.state = :read
      reading.save!
    rescue ActiveRecord::RecordNotUnique
      # Database-level uniqueness constraint failed.
      return true
    end

    def unread_by!(user)
      Reading.update_all({:state => :unread}, :user_id => user.id, :readable_id => self.id, :readable_type => self.class.name)
    end

    def read_by?(user)
      if cached_reading
        cached_reading.read?
      elsif cached_reading == false
        user[acts_as_readable_options[:cache]].to_f > self.updated_at.to_f
      elsif readers.loaded?
        readers.include?(user)
      elsif reading = readings.find_by_user_id(user.id)
        reading.read?
      else
        user[acts_as_readable_options[:cache]].to_f > self.updated_at.to_f
      end
    end
    
    def unread_by?(user)
      !read_by(user)
    end    
  end
end

