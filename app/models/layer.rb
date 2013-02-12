require 'net/http'
require 'uri'

class Layer
  include Mongoid::Document
  include Mongoid::Timestamps
  
  acts_as_nested_set
  
  field :slug,        type: String
  field :name,        type: String
  field :data_type,   type: String
  field :data_value,  type: String
  field :wms_layers,  type: String
  field :wms_query_url, type: String
  field :wms_legend_url, type: String
  field :projection,  type: String
  field :attribution,   type: String
  field :popup_template, type: String
  field :select_by_default, type: Boolean, default: true
  
  index({ name: 1, data_type: -1, lft: 1 })
  
  embeds_one :style
  embeds_one :filter
  embeds_many :rules
  
  # has_many :children, class_name: 'Layer', inverse_of: :parent, dependent: :destroy
  # belongs_to :parent, class_name: 'Layer', inverse_of: :children, touch: true
  
  has_and_belongs_to_many :maps
  # embeds_one :geojson
  # embeds_one :gpx
  
  # accepts_nested_attributes_for :style
  
  after_save :touch_maps
  
  validates_presence_of :slug
  validates_presence_of :name
  validates_presence_of :data_type
  validates_presence_of :data_value
  validates_presence_of :projection
  
  #sort this way by default so that tile layers show up on bottom
  #TODO: find a better way to do this
  default_scope asc(:name).desc(:data_type)
  
  def to_param
    self.slug
  end
  
  def touch_maps
    self.maps.each(&:touch)
  end
  
  def split_on_field(field, opts={})
    return false unless %w[proxy geojson].include? self.data_type
    
    self.get_unique_values_for(field, opts).collect do |v|
      Layer.create(
        name: v.humanize, 
        slug: "#{self.slug}-#{v.parameterize}", 
        data_type: self.data_type, 
        data_value: URI.escape("#{self.data_value}?properties[#{field}]=#{v}"), 
        style: Style.new(self.style.attributes),
        filter: Filter.new(self.filter.attributes),
        projection: self.projection,
        select_by_default: true,
        parent: self
      )
    end    
  end
  
  def legend?
    !self.wms_legend_url.nil? and !self.wms_legend_url.empty?
  end
  
  def get_legend
    if legend?
      Net::HTTP.get(URI.parse(self.wms_legend_url))
    end 
  end
  
  def get_unique_values_for(field, opts={})
    return false unless %w[proxy geojson].include? self.data_type
    
    opts[:except] ||= []
    opts[:only] ||= []    
    
    values = []
    self.parsed_data['features'].each do |feature|
      value = feature['properties'][field]
      next if opts[:only].include? value and !opts[:except].include? value
      
      value = value.downcase if value.respond_to? :downcase
      values << value 
      values.uniq!
    end
    
    values
  end
    
  def classify_field(field, override_style = {}, opts = {})
    return false unless %w[proxy geojson].include? self.data_type
    
    values = self.get_unique_values_for(field, opts)
    
    values.uniq.compact.sort!
    values.unshift nil if opts[:else] # put the else rule first
    
    rule_style = Style.new(self.style.attributes)
    override_style.each { |k,v| rule_style.send("#{k}=", v) }
    
    uri.object = 
    
    values.each do |v|
      handler = v.nil? ? 'ELSE' : '~'
      
      label = v.respond_to?(:humanize) ? v.humanize : v
      label ||= 'Default'
      
      r = self.rules.build(
            field: field, 
            handler: handler, 
            values: v.to_s || '', 
            legendLabel: label, 
            style: v.nil? ? Style.new(self.style.attributes) : rule_style)
    end
  end
  
  def parsed_data
    case self.data_type.to_sym
    when :proxy
      JSON.parse(self.raw_data)
    when :geojson
      JSON.parse(self.raw_data)
    else
      self.raw_data
    end
  end
  
  def raw_data
    case self.data_type.to_sym
    when :proxy
      d, ext = self.data_value.split('.').last.match(/([^?]*)(.*)/).to_a
      
      Net::HTTP.get(URI.parse(self.data_value))
    when :geojson
      self.data_value
    when :gpx
      self.data_value
    when :tiles
      self.data_value
    when :wms
      self.data_value
    else
      raise "Unhandled data type #{self.data_typ}"
    end
  end
  
  def as_json(*args)
    data = super
    data[:type] = self.data_type
    data.delete('data_type')
    data.delete('data_value')
    
    if self.data_type.to_sym == :proxy
      data[:type] = 'geojson'
      data[:geojson] = self.parsed_data
    else
      data[self.data_type.to_sym] = self.parsed_data
    end
    
    data[:rules] = self.rules.as_json
    
    data
  end
end
