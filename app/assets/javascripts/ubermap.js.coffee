class @UberMap
  init: () ->
    @initMap()
    
  initMap: () ->
    Proj4js.defs["EPSG:3338"] = "+proj=aea +lat_1=55 +lat_2=65 +lat_0=50 +lon_0=-154 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs";
    Proj4js.defs["ORTHOGRAPHIC"] = "+proj=ortho +lat_0=64.837780 +lon_0=-147.71639"
    
    config = Gina.Projections.get 'EPSG:3338'
  
    @map = new OpenLayers.Map {
      div: 'map',
      projection: config.projection,
      maxExtent: config.maxExtent,
      maxResolution: config.maxResolution,
      units: config.units,
    
      controls: [
          new OpenLayers.Control.LayerSwitcher(),
          new OpenLayers.Control.Navigation(),
          new OpenLayers.Control.PanZoom(),
          new OpenLayers.Control.Attribution()
      ],
      numZoomLevels: 18
    }
    
    Gina.Layers.inject @map, 'TILE.EPSG:3338.*'
    
    bounds = new OpenLayers.Bounds -2395996.09375, 99121.09375, 2525878.90625, 2703613.28125
    @map.zoomToExtent bounds
  #end initMap
  
  aoiAdd: (feature) ->
    @navigateClick()
    request = new MapRequest({ wkt: feature.geometry.toString() })
    request.send()

  navigateClick: () ->
    @aoiHandler.deactivate()
    $('#map-buttons .btn[name="navigate"]').button('toggle')

  aoiClick: () ->
    @aoiLayer.removeAllFeatures()
    @aoiHandler.activate()
#end UberMap