module LayersHelper
  GRAPHIC_SIZE = 32
  
  def legend_text(rule)
    if not rule.legendLabel.empty?
      rule.legendLabel
    else
      "#{rule.field.humanize} #{rule.handler.to_s.humanize} #{rule.values}"
    end
  end

  def stored_style_javascript(el, style)
    #TODO add support for other types of legend features
    case style['graphicName']
    when 'image'
      config = image_legend(style)          
    when 'circle'
      config = circle_legend(style)    
    when 'square'
      config = square_legend(style)    
    end
    
    content_for :styles_javascript do
      output = "var el = Raphael([$('##{el}')[0], #{GRAPHIC_SIZE}, #{GRAPHIC_SIZE}, #{config.to_json}]);"
      output << "el.transform('r#{style['rotation']}');" if style['rotation']
      output.html_safe
    end
  end

  def stored_rule_javascript(el, rule)
    style = rule.layer.style.as_json
    style.merge!(rule.style.as_json)
    
    stored_style_javascript(el, style)
  end
  
  def circle_legend(style)
    center = GRAPHIC_SIZE/2
    
    {
      type: "circle",
      cx: center, 
      cy: center,
      r: (style['pointRadius'] || 10),
      stroke: style['strokeColor'] || '#f00',
      "stroke-opacity" => style['strokeOpacity'] || 1,
      "stroke-width" => style['strokeWidth'] || 1,
      fill: style['fillColor'] || '#f00',
      "fill-opacity" => style['fillOpacity'] || 1
    }
  end  
  
  def image_legend(style)
    size = (style['pointRadius'] || 10)*2
    center = (GRAPHIC_SIZE - size)/2
    
    {
      type: "image",
      src: style['externalGraphic'],
      x: center, 
      y: center,
      width: size,
      height: size
    }
  end
  
  def square_legend(style)
    size = (style['pointRadius'] || 10)*2
    center = (GRAPHIC_SIZE - size)/2
    
    {
      type: 'rect',
      x: center,
      y: center,
      width: size,
      height: size,
      stroke: style['strokeColor'] || '#f00',
      "stroke-opacity" => style['strokeOpacity'] || 1,
      "stroke-width" => style['strokeWidth'] || 1,
      fill: style['fillColor'] || '#f00',
      "fill-opacity" => style['fillOpacity'] || 1
    }
  end
end
