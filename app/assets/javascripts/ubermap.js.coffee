class @UberMap
  init: (projection) ->
    @initMap(projection)
    
  initMap: (projection) ->
    Proj4js.defs["EPSG:3338"] = "+proj=aea +lat_1=55 +lat_2=65 +lat_0=50 +lon_0=-154 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs";
    Proj4js.defs["EPSG:3572"] = "+proj=laea +lat_0=90 +lon_0=-150 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs";
    
    config = Gina.Projections.get projection
  
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
    
    Gina.Layers.inject @map, "TILE.#{projection}.*"
    @handleHistoryState()
  #end initMap
  
  loadState: (state) =>
    if state && state.lat && state.lon && state.zoom
      center = new OpenLayers.LonLat(state.lon, state.lat)
      center.transform(new OpenLayers.Projection('EPSG:4326'), @map.getProjectionObject())
      
      console.log(center)
      
      @map.setCenter(center)
      @map.zoomTo(state.zoom)
    else    
      bounds = new OpenLayers.Bounds -178.00173053759866,50.46509481762141,-106.7350762188874,68.8621532986179
      bounds.transform(new OpenLayers.Projection('EPSG:4326'), @map.getProjectionObject())
      @map.zoomToExtent bounds
    #end if
    
    console.log @map.getCenter(), state
  #end loadState
  
  handleHistoryState: () =>
    @loadState(history.state)
    
    @map.events.register 'moveend', this, () =>
      return if @preventHistoryUpdate
      
      center = @map.getCenter()
      center.transform(@map.getProjectionObject(), new OpenLayers.Projection('EPSG:4326'))
      params = { "lat": center.lat.toFixed(3), "lon": center.lon.toFixed(3), "zoom": @map.getZoom() }
      url = '/?' + $.param(params)
      
      history.pushState(params, null, url)
      
    $(window).on 'popstate', (e) =>
      @preventHistoryUpdate = true
      @loadState(e.originalEvent.state) unless e.originalEvent.state == null
      @preventHistoryUpdate = false
  
    #end register
  #end handleHistoryState
  
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
  
  aoiAdd: (feature) ->
    @navigateClick()
    request = new MapRequest({ wkt: feature.geometry.toString() })
    request.send()

  aoiClick: () ->
    @aoiLayer.removeAllFeatures()
    @aoiHandler.activate()
#end UberMap