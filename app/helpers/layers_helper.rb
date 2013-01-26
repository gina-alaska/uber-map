module LayersHelper
  GRAPHIC_SIZE = 32
  
  def popup_template(layer, data)
    context = {
      data: data,
      whitelist: HTML::Pipeline::SanitizationFilter::WHITELIST.merge(
        :attributes => {
          'a' => ['href', 'class', 'data-slide'],
          'img' => ['src', 'alt', 'style'],
          'div' => ['itemscope', 'itemtype', 'style'],
          :all => ['abbr', 'accept', 'accept-charset',
                    'accesskey', 'action', 'align', 'alt', 'axis',
                    'border', 'cellpadding', 'cellspacing', 'char',
                    'charoff', 'charset', 'checked', 'cite',
                    'clear', 'cols', 'colspan', 'color',
                    'compact', 'coords', 'datetime', 'dir',
                    'disabled', 'enctype', 'for', 'frame',
                    'headers', 'height', 'hreflang',
                    'hspace', 'ismap', 'label', 'lang',
                    'longdesc', 'maxlength', 'media', 'method',
                    'multiple', 'name', 'nohref', 'noshade',
                    'nowrap', 'prompt', 'readonly', 'rel', 'rev',
                    'rows', 'rowspan', 'rules', 'scope',
                    'selected', 'shape', 'size', 'span',
                    'start', 'summary', 'tabindex', 'target',
                    'title', 'type', 'usemap', 'valign', 'value',
                    'vspace', 'width', 'itemprop', 'id', 'class']
        }
      )
    }
  
    if !layer.popup_template.nil? and !layer.popup_template.empty?
      pipeline = HTML::Pipeline.new([
        LiquidFilter,
        HTML::Pipeline::AutolinkFilter,
        HTML::Pipeline::SanitizationFilter
      ], context)
    
      content_tag('div', class: 'feature-popup-content') do
        pipeline.call(layer.popup_template)[:output].to_s.html_safe
      end.html_safe
    else
      default_popup_template(data)
    end
  end
  
  def default_popup_template(data)
    content_tag('div', class: 'feature-popup-content') do
      output = ''
      data.each do |k,v|
        next if v.nil? or v.empty?
        output << content_tag('div', class: 'item') do
          "<label>#{k.humanize}:</label>".html_safe + v
        end
      end
      output.html_safe
    end
  end
  
  def legend_text(rule)
    if not rule.legendLabel.empty?
      rule.legendLabel
    else
      "#{rule.field.humanize} #{rule.handler.to_s.humanize} #{rule.values}"
    end
  end

  def legend_style_javascript(el, style)
    #TODO add support for other types of legend features
    config = style.as_raphael_config
    
    output = "var el = Raphael([$('##{el}')[0], #{Style::GRAPHIC_SIZE}, #{Style::GRAPHIC_SIZE}, #{config.to_json}]);"
    output << "el.transform('r#{style['rotation']}');" if style['rotation']
    output.html_safe
  end
  
  def style_to_config(style)
    case style['graphicName']
    when 'image'
      image_legend(style)          
    when 'circle'
      circle_legend(style)    
    when 'square'
      square_legend(style)    
    end
  end

  def legend_rule_javascript(el, rule)
    config = rule.style.as_raphael_config
    # config.merge!(rule.layer.style.as_raphael_config)
    
    output = "var el = Raphael([$('##{el}')[0], #{Style::GRAPHIC_SIZE}, #{Style::GRAPHIC_SIZE}, #{config.to_json}]);"
    output << "el.transform('r#{style['rotation']}');" if config['rotation']
    output.html_safe
  end
end
