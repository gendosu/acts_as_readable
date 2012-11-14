class Reading < ActiveRecord::Base
  belongs_to :user
  belongs_to :readable, :polymorphic => true
  
  validates_presence_of :user_id, :readable_id, :readable_type
  validates_inclusion_of :state, :in => [:read, :unread, 'read', 'unread']
  
  def read?
    self.state == 'read'
  end
  
  def unread?
    self.state == 'unread'
  end
end