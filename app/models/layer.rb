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
  
  #sort this way by default so that tile layers show up on bottom
  #TODO: find a better way to do this
  default_scope desc(:data_type)
  
  def to_param
    self.slug
  end
  
  def as_json(*args)
    data = super
    data[:type] = self.data_type
    data.delete('data_type')
    data.delete('data_value')
    
    case self.data_type.to_sym
    when :proxy
      d, ext = self.data_value.split('.').last.match(/([^?]*)(.*)/).to_a
      
      response = Net::HTTP.get(URI.parse(self.data_value))
      case ext.to_sym
      when :geojson
        data[:type] = :geojson
        data[:geojson] = JSON.parse(response)
      else
        data[:type] = ext.to_sym
        data[:geojson] = response
      end
    when :gpx
    when :geojson
      data[:geojson] = JSON.parse(self.data_value)
    else
      data[self.data_type] = self.data_value
    end
    
    data[:rules] = self.rules.as_json
    
    data
  end
end
