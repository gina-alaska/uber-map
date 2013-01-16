# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
class @LayerFeed
  constructor: (map_projection, source_proj) ->
    @builder = new StyleBuilder()
    
    if source_proj != map_projection
      @do_transform = true
      @source = new OpenLayers.Projection(source_proj)
      @dest = new OpenLayers.Projection(map_projection)
    #end if
  #end constructor
    
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
    #end if
    
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
    
    layer
  #end tiles
    
  vector: (data) ->
    config = { attribution: data.attribution, wrapDateLine: true, rendererOptions: {zIndexing: true}, displayInLayerSwitcher: false }
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
    layer.addFeatures(features)
    
    layer
  #end vector
#end VectorFeed