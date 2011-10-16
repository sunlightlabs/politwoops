class Group < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :full_name
  
  has_and_belongs_to_many :politicians
  
  default_scope :order => :name
  
  scope :visible, :conditions => "hide = 0"
end
