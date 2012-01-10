module ActsAsReadable
  module ActMethod  
    def acts_as_readable
      has_many :readings, :as => :readable
      has_many :readers, :through => :readings, :source => :user

      scope :read_by, lambda {|user| where("#{user.id} IN (SELECT user_id FROM readings WHERE readable_type = '#{name}' AND readable_id = #{table_name}.id)") }
      scope :unread_by, lambda {|user| where("#{user.id} NOT IN (SELECT user_id FROM readings WHERE readable_type = '#{name}' AND readable_id = #{table_name}.id)") }
      scope :update_unread_by, lambda {|user| where("? IN (SELECT user_id FROM readings WHERE readable_type = '#{name}' AND readable_id = #{table_name}.id) AND ? NOT IN (SELECT user_id FROM readings WHERE readable_type = '#{name}' AND readable_id = #{table_name}.id AND (#{table_name}.updated_at < readings.updated_at OR #{table_name}.updated_at < readings.created_at))", user.id, user.id) }
      scope :creation_or_update_unread_by, lambda {|user| where("? NOT IN (SELECT user_id FROM readings WHERE readable_type = '#{name}' AND readable_id = #{table_name}.id AND #{table_name}.updated_at < readings.updated_at)", user.id) }

      extend ActsAsReadable::ClassMethods
      include ActsAsReadable::InstanceMethods
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
      reading.save!
    rescue ActiveRecord::RecordNotUnique
      # Database-level uniqueness constraint failed.
      return true
    end

    def unread_by!(user)
      Reading.delete_all(:user_id => user.id, :readable_id => self.id, :readable_type => self.class.name)
    end

    def read_by?(user)
      case cached_reading
      when nil
        readers.loaded? ? readers.include?(user) : readers.exists?(user)
      else
        cached_reading
      end
    end

    # Returns true if the user has read this at least once, but it has been updated since the last reading
    def updated?(user)
      read_by?(user) && !latest_update_read_by?(user)
    end

    def latest_update_read_by?(user)
      case cached_reading
      when nil
        readings.exists?(["user_id = ? AND (? < readings.updated_at OR ? < readings.created_at)", user.id, self.updated_at, self.updated_at])
      when false
        false
      else
        cached_reading.updated_at > self.updated_at
      end      
    end
  end
end

