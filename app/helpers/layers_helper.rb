module LayersHelper
  def handler_text(handler)
    case handler
    when '>='
      ' greater than or equal to '
    when '>'
      ' greater than '
    when '<='
      ' less than or equal to '
    when '<'
      ' less than '
    when 'between'
      ' between '
    else
      handler.to_s.humanize
    end
  end
  
  def stored_rule_javascript(el, rule)
    #TODO add support for other types of legend features
    config = circle_legend(el, rule)
    
    content_for :rules_javascript do
      "Raphael(['#{el}', 24, 24, #{config.to_json}]);".html_safe
    end
  end
  
  def circle_legend(el, rule)
    style = rule.layer.style.as_json
    style.merge!(rule.style.as_json)
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
