class Map
  include Mongoid::Document
  
  field :slug,        type: String
  field :title,       type: String
  field :description, type: String
  
  has_and_belongs_to_many :layers
  
  def url
    "http://#{self.slug}.#{Ubermap::Application.config.base_url}/"
  end
end
