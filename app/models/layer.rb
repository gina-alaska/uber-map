require 'net/http'
require 'uri'

class Layer
  include Mongoid::Document
  
  field :slug,        type: String
  field :name,        type: String
  field :data_type,   type: String
  field :data_value,  type: String
  field :projection,  type: String
  
  embeds_one :style
  embeds_one :filter
  embeds_many :rules
  
  has_and_belongs_to_many :maps  
  # embeds_one :geojson
  # embeds_one :gpx
  
  # accepts_nested_attributes_for :style
  
  validates_presence_of :slug
  validates_presence_of :name
  validates_presence_of :data_type
  validates_presence_of :data_value
  validates_presence_of :projection
  
  def to_param
    self.slug
  end
  
  def as_json(*args)
    data = super
    data.delete('data_type')
    data.delete('data_value')
    
    case self.data_type.to_sym
    when :proxy
      ext = self.data_value.split('.').last
      response = Net::HTTP.get(URI.parse(self.data_value))
      case ext.to_sym
      when :geojson
        data[ext] = JSON.parse(response)
      else
        data[ext] = response
      end
    when :geojson
      data[self.data_type] = JSON.parse(self.data_value)
    else
      data[self.data_type] = self.data_value
    end
    
    data[:rules] = self.rules.as_json
    
    data
  end
end
