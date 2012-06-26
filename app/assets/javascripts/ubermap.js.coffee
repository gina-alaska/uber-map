class @UberMap
  init: () ->
    @initMap()
    
  initMap: () ->
    Proj4js.defs["EPSG:3338"] = "+proj=aea +lat_1=55 +lat_2=65 +lat_0=50 +lon_0=-154 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs";
    
    config = Gina.Projections.get 'EPSG:3338'
  
    @map = new OpenLayers.Map {
      div: 'map',
      projection: config.projection,
      maxExtent: config.maxExtent,
      maxResolution: config.maxResolution,
      units: config.units,
    
      controls: [
          new OpenLayers.Control.LayerSwitcher(),
          new OpenLayers.Control.Navigation({
            dragPanOptions: {
              enableKinetic: true
            }
          }),
          new OpenLayers.Control.Zoom(),
          new OpenLayers.Control.Attribution()
      ],
      numZoomLevels: 18
    }
    
    Gina.Layers.inject @map, 'TILE.EPSG:3338.*'
    
    bounds = new OpenLayers.Bounds -1791015.625,290927.2460938,1708984.375,2533114.7460938
    @map.zoomToExtent bounds
  #end initMap
  
  aoiAdd: (feature) ->
    @navigateClick()
    request = new MapRequest({ wkt: feature.geometry.toString() })
    request.send()

  aoiClick: () ->
    @aoiLayer.removeAllFeatures()
    @aoiHandler.activate()
#end UberMap