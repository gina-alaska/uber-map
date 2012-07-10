# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
class @LayerFeed
  constructor: (map, source_proj, dest_proj) ->
    @map = map
    @builder = new StyleBuilder()
    @vector_layers = []
    
    @feed_select_control = new OpenLayers.Control.SelectFeature([], {
      onSelect: @onFeatureSelect,
      onUnselect: @onFeatureUnselect 
    })
    @map.addControl(@feed_select_control)
    @feed_select_control.activate()
    
    if source_proj != dest_proj
      @do_transform = true
      @source = new OpenLayers.Projection(source_proj)
      @dest = new OpenLayers.Projection(dest_proj)
    #end if
  #end constructor
  
  onFeatureSelect: (feature) =>
    content = for key, value of feature.attributes
      "<div class=\"item item-#{key}\"><label>#{key.replace(/_/g, ' ')}:</label> #{value}</div>"
    #end for
      
    content = '<div class="feature-popup-content">' + content.join('') + '</div>'
          
    popup = new OpenLayers.Popup.FramedCloud("popup-"+feature.id, 
       feature.geometry.getBounds().getCenterLonLat(),
       null,
       content, null, true);
    @map.addPopup(popup);
    
  onFeatureUnselect: () =>
  #end onFeatureUnselect  
      
  transform: (features) ->
    return false if !features
    for f in features
      f.geometry.transform(@source, @dest)  
      f 
    #end for
  #end transform
  
  geojson: (data) ->
    parser = new OpenLayers.Format.GeoJSON()
    if data.geojson
      features = parser.read(data.geojson)    
    else if data.type && data.type == 'FeatureCollection'
      features = parser.read(data)    
    #end
    
    if @do_transform == true
      features = @transform(features)
    
    features
  #end geojson
  
  gpx: (data) ->
    parser = new OpenLayers.Format.GPX()
    features = parser.read(data)    
    
    if @do_transform == true
      features = @transform(features)
    
    features    
  #end gps
  
  parseFeatures: (data) ->
    if data.geojson
      type = 'geojson'
    else if data.gpx
      type = 'gpx'
    else
      # assume geojson as default
      type = 'geojson'
    #end if
    
    switch type
      when 'geojson'
        return @geojson(data)
      when 'gpx'
        return @gpx(data.gpx)
    #end switch
  #end parseFeatures
  
  createLayer: (data) ->
    switch data.type
      when 'tiles'
        @tiles(data)
      else
        @vector(data)
    #end switch
  #end createLayer
  
  tiles: (data) ->
    config = { attribution: data.attribution, isBaseLayer: false, opacity: 0.5, displayInLayerSwitcher: false }
    
    layer = new OpenLayers.Layer.XYZ(data.name, data.tiles, config)
    @map.addLayer(layer)
    
    layer
  #end tiles
    
  vector: (data) ->
    config = { attribution: data.attribution, rendererOptions: {zIndexing: true}, displayInLayerSwitcher: false }
    features = @parseFeatures(data)
    
    if data.style || data.rules
      config.styleMap = @builder.build(data.style, data.rules, features)
    #end if
    
    # filters = new FilterBuilder()
    # 
    # dateFilter = filters.date('start_time', Date.parse('2012/06/21'), Date.parse('2012/06/21 23:59:59'), features);
    # config.strategies = [filters.buildStrat(dateFilter)];
    # 
    layer = new OpenLayers.Layer.Vector(data.name || 'Vector', config)
    @map.addLayer(layer)
    
    layer.addFeatures(features)
    
    @vector_layers.push layer
    @feed_select_control.setLayer(@vector_layers)
    layer
  #end vector
#end VectorFeed
