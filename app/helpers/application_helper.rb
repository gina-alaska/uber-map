module ApplicationHelper
  def flash_messages
    output = ''
    [:success, :error].each do |type|
      next if flash[type].nil?
      
      output << <<-EOHTML
      <div class="alert alert-#{type}">
        <button class="close" data-dismiss="alert">X</button>
        #{flash[type]}
      </div> 
      EOHTML
    end
    
    output.html_safe
  end
  
  def add_js_errors_for(model)
    klass = model.class.to_s.downcase
    output = ''
    
    model.errors.each do |field,msg|
      output << "
        $('##{klass}_#{field}').parents('.control-group').addClass('error');
        $('##{klass}_#{field}').tooltip({ title: \"#{field.to_s.humanize} #{ msg }\" });
      "
    end
    
    output.html_safe
  end
  
  def spinner(el, disable = false)
    if disable
      config = false
    else
      config = {
        lines: 11,            # The number of lines to draw
        length: 4,            # The length of each line
        width: 2,             # The line thickness
        radius: 6,            # The radius of the inner circle
        rotate: 0,            # The rotation offset
        color: '#FFF',        # #rgb or #rrggbb
        speed: 1.4,           # Rounds per second
        trail: 68,            # Afterglow percentage
        shadow: true,         # Whether to render a shadow
        hwaccel: false,       # Whether to use hardware acceleration
        className: 'spinner', # The CSS class to assign to the spinner
        zIndex: 2e9,          # The z-index (defaults to 2000000000)
        top: 'auto',          # Top position relative to parent in px
        left: 'auto'          # Left position relative to parent in px
      }
    end
    
    <<-EOJS
    $('#{el}').spin(#{config.to_json});
    EOJS
  end
  
  def filter(layer)
    return unless layer.filter
    case layer.filter.type.to_sym
    when :dateslider
      "filters.dateslider('#layer-legend-#{layer.slug}', layer, #{layer.filter.to_json})"
    when :slider
      "filters.slider('#layer-legend-#{layer.slug}', layer, #{layer.filter.to_json})"
    end
  end
  
  def load_all_map_layers(map)
    output = ""
    map.layers.each do |layer|
      output << <<-EOJS

      var feed = new VectorFeed(uber.map, '#{layer.projection}', 'EPSG:3338'); 
      var filters = new FilterBuilder();     
      
      #{spinner("#layer-legend-#{layer.slug} .spinner")}
      
      $.get('#{layer_path(layer, format: :json)}', function(data) {
        var layer = feed.createLayer(data);
        var control = new OpenLayers.Control.SelectFeature(layer, {
          onSelect: uber.onFeatureSelect,
          onUnselect: uber.onFeatureUnselect 
        });
        uber.map.addControl(control);
        control.activate();
        
        #{spinner("#layer-legend-#{layer.slug} .spinner", true)}
        #{filter(layer)}
      });
      
      EOJS
    end
    
    output
  end
end
