class Style
  include Mongoid::Document
  
  field :pointRadius,     type: Integer
  field :strokeWidth,     type: Float
  field :strokeColor,     type: String
  field :strokeOpacity,   type: Float
  field :fillColor,       type: String
  field :fillOpacity,     type: Float
  field :graphicZIndex,   type: Integer
  
  embedded_in :layer
  
  def as_json(*args)
    data = super
    data.reject { |k,v| v.nil? }
  end
end
