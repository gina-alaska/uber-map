class Style
  include Mongoid::Document
  
  field :pointRadius,     type: Integer, default: 10
  field :strokeWidth,     type: Float, default: 1
  field :strokeColor,     type: String
  field :strokeOpacity,   type: Float, default: 1
  field :fillColor,       type: String
  field :fillOpacity,     type: Float, default: 1
  field :graphicZIndex,   type: Integer
  field :graphicName,     type: String
  field :externalGraphic, type: String
  field :rotation,        type: Integer
  
  embedded_in :layer
  
  def as_json(*args)
    data = super
    data.reject { |k,v| v.nil? }
    
    if self.pointRadius
      data[:graphicWidth] = self.pointRadius.to_f * 2 
      data[:graphicHeight] = self.pointRadius.to_f * 2
    end
    
    data
  end
end
