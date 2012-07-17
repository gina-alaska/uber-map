class @UberMap
  init: (projection) ->
    @initMap(projection)
    
  initMap: (projection) ->
    Proj4js.defs["EPSG:3338"] = "+proj=aea +lat_1=55 +lat_2=65 +lat_0=50 +lon_0=-154 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs";
    Proj4js.defs["EPSG:3572"] = "+proj=laea +lat_0=90 +lon_0=-150 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs";
    Proj4js.defs["EPSG:3857"] = "+proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=0 +a=6378137 +b=6378137 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs";
    
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
      
      @map.setCenter(center)
      @map.zoomTo(state.zoom)
    else    
      bounds = new OpenLayers.Bounds -175.1330784368692,55.700549954048114,-126.8228511740872,68.84008605441156
      bounds.transform('EPSG:4326', @map.getProjectionObject())
      @map.zoomToExtent bounds
    #end if
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
  
  aoiAdd: (feature) ->
    @navigateClick()
    request = new MapRequest({ wkt: feature.geometry.toString() })
    request.send()

  aoiClick: () ->
    @aoiLayer.removeAllFeatures()
    @aoiHandler.activate()
  #end aoiClick
  
  message: (message) ->
    $('#map-messages').append('<div class="alert alert-error">' + 
      '<a class="close" data-dismiss="alert" href="#">x</a><h4 class="alert-heading">Error!</h4>' +
      message +
      '</div>'
    )
  #end message
#end UberMap