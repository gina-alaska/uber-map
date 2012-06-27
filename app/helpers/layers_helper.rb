module LayersHelper
  def handler_text(handler)
    handler.to_s.humanize
  end

  def stored_style_javascript(el, style)
    #TODO add support for other types of legend features
    config = circle_legend(el, style)    
    
    content_for :styles_javascript do
      "Raphael(['#{el}', 24, 24, #{config.to_json}]);".html_safe
    end
  end

  
  def stored_rule_javascript(el, rule)
    style = rule.layer.style.as_json
    style.merge!(rule.style.as_json)
    
    stored_style_javascript(el, style)
  end
  
  def circle_legend(el, style)
    {
      type: "circle",
      cx: 12, 
      cy: 12,
      r: style['pointRadius'] || 10,
      stroke: style['strokeColor'] || '#f00',
      "stroke-opacity" => style['strokeOpacity'] || 1,
      "stroke-width" => style['strokeWidth'] || 1,
      fill: style['fillColor'] || '#f00',
      "fill-opacity" => style['fillOpacity'] || 1
    }
  end
end
