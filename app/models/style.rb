class Style
  include Mongoid::Document
  
  GRAPHIC_SIZE = 32
  
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
  
  def as_raphael_config
    case self.graphicName
    when 'image'
      image_legend          
    when 'circle'
      circle_legend
    when 'square'
      square_legend
    end
  end
  
  def as_json(*args)
    data = super
    data.reject { |k,v| v.nil? }
    
    if self.pointRadius
      data[:graphicWidth] = self.pointRadius.to_f * 2 
      data[:graphicHeight] = self.pointRadius.to_f * 2
    end
    
    data
  end
  
  def circle_legend
    center = GRAPHIC_SIZE/2
    
    {
      type: "circle",
      cx: center, 
      cy: center,
      r: (self.pointRadius || 10),
      stroke: self.strokeColor || '#f00',
      "stroke-opacity" => self.strokeOpacity || 1,
      "stroke-width" => self.strokeWidth || 1,
      fill: self.fillColor || '#f00',
      "fill-opacity" => self.fillOpacity || 1
    }
  end  
  
  def image_legend
    size = (self.pointRadius || 10)*2
    center = (GRAPHIC_SIZE - size)/2
    
    {
      type: "image",
      src: self.externalGraphic,
      x: center, 
      y: center,
      width: size,
      height: size
    }
  end
  
  def square_legend
    size = (self.pointRadius || 10)*2
    center = (GRAPHIC_SIZE - size)/2
    
    {
      type: 'rect',
      x: center,
      y: center,
      width: size,
      height: size,
      stroke: self.strokeColor || '#f00',
      "stroke-opacity" => self.strokeOpacity || 1,
      "stroke-width" => self.strokeWidth || 1,
      fill: self.fillColor || '#f00',
      "fill-opacity" => self.fillOpacity || 1
    }
  end
end
