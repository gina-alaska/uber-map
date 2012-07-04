class Map
  include Mongoid::Document
  
  field :slug,        type: String
  field :title,       type: String
  field :description, type: String
  field :projection,  type: String, default: 'EPSG:3338'
  field :active,      type: Boolean, default: false
  
  has_and_belongs_to_many :layers
  
  scope :active, where(:active => true)
  
  def to_param
    self.slug
  end
  
  def url
    "http://#{self.slug}.#{Ubermap::Application.config.base_url}/"
  end
  
  def title_with_status
    if !active
      self.title + ' (disabled)'
    else
      self.title
    end
  end
  
  def admin_url
    url + 'admin'
  end
end
