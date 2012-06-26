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
  
  def load_all_map_layers(map)
    output = ""
    map.layers.each do |layer|
      output << <<-EOJS

      var feed = new VectorFeed(uber.map, '#{layer.projection}', 'EPSG:3338');      
      var legend = new LegendBuilder();
      
      $.get('#{layer_path(layer, format: :json)}', function(data) {
        var layer = feed.createLayer(data);
        var control = new OpenLayers.Control.SelectFeature(layer, {
          onSelect: uber.onFeatureSelect,
          onUnselect: uber.onFeatureUnselect 
        });
        uber.map.addControl(control);
        control.activate();
      })
      EOJS
    end
    
    output
  end
end
