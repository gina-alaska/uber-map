class @FilterBuilder
  constructor: () ->
    
  #end constructor
  
  dateslider: (el, layer, config) ->
    field = config.field
    min = null
    max = null
    for feature in layer.features
      feature.attributes[field + '_seconds'] = Date.parse(feature.attributes[field])
      feature.attributes[field] = new Date(feature.attributes[field])
      v = feature.attributes[field + '_seconds']
      min = v if v < min || min == null
      max = v if v > max || max == null
    #end for
    
    #default to only show first item
    filter = @date(field + '_seconds', min, min)
    strat = @buildStrat(filter, layer)
    
    updateFilter = (values) =>
      filter.lowerBoundary = values[0]
      filter.upperBoundary = values[1]
      strat.setFilter(filter)
      format = '%Y-%M-%d %H:%m'
      $(el + ' .slider-text').html(new Date(values[0]).toLocaleString(format) + ' - ' + new Date(values[1]).toLocaleString(format))
    
    $(el + ' .slider').slider({
      range: true,
      min: min,
      max: max,
      values: [min, min],
      slide: (e, ui) =>
        updateFilter(ui.values)
      #end slide
    })
    updateFilter([min,min])
  #end dateslider
  
  opacityslider: (el, layer, config) ->
    $(el + ' .slider').slider({
      min: 0,
      max: 100,
      value: 50,
      slide: (e, ui) =>
        $(el + ' .slider-text').html(ui.value + '%')
        layer.setOpacity(ui.value / 100)
      #end slide
    })    
    $(el + ' .slider-text').html('Opacity: 50%')
  
  layerslider: (el, layer, config) ->
    field = config.field
    display_field= config.display_field
    
    min = 0
    max = layer.features.length - 1
    labels = {}
    for feature, i in layer.features
      feature.attributes['index'] = i
      labels[i] = feature.attributes[display_field] if display_field
    #end for
    
    filter = @only('index', min)
    strat = @buildStrat(filter, layer)
    
    updateFilter = (value) =>
      filter.value = value
      strat.setFilter(filter)
      if labels[value]
        $(el + ' .slider-text').html(labels[value])
      else
        $(el + ' .slider-text').html(value)        
      #end if
      
      if strat.timer
        clearTimeout(strat.timer)
      #end if
      strat.timer = setTimeout(() =>
        if strat.filteredLayer
          strat.filteredLayer.removeMap()
          strat.filteredLayer.destroy()
        #end if
        
        url = layer.features[0].attributes[field] + '${x}/${y}/${z}'       
        if url
          config = { isBaseLayer: false, opacity: 1, wrapDateLine: true, displayInLayerSwitcher: false }
          strat.filteredLayer = new OpenLayers.Layer.XYZ('test', url, config)
          uber.map.addLayer(strat.filteredLayer)
        #end if
      , 3000)
    #end updateFilter
    
    
    $(el + ' .slider').slider({
      min: min,
      max: max,
      value: min,
      slide: (e, ui) =>
        updateFilter(ui.value)
      #end slide
    })
    updateFilter(min)
  #end slider
  
  slider: (el, layer, config) ->
    field = config.field
    display_field= config.display_field
    
    min = null
    max = null
    labels = {}
    for feature in layer.features
      v = feature.attributes[field]
      labels[v] = feature.attributes[display_field] if display_field
      min = v if v < min || min == null
      max = v if v > max || max == null
    #end for
    
    filter = @only(field, min)
    strat = @buildStrat(filter, layer)
    
    updateFilter = (value) =>
      filter.value = value
      strat.setFilter(filter)
      if labels[value]
        $(el + ' .slider-text').html(labels[value])
      else
        $(el + ' .slider-text').html(value)        
      #end if
    
    $(el + ' .slider').slider({
      min: min,
      max: max,
      value: min,
      slide: (e, ui) =>
        updateFilter(ui.value)
      #end slide
    })
    updateFilter(min)
  #end slider
  
  only: (field, value) ->    
    new OpenLayers.Filter.Comparison({
      type: OpenLayers.Filter.Comparison.EQUAL_TO,
      property: field,
      value: value
    });
  #end only  
  
  date: (field, start_at, end_at, features) ->
    new OpenLayers.Filter.Comparison({
      type: OpenLayers.Filter.Comparison.BETWEEN,
      property: field,
      lowerBoundary: start_at,
      upperBoundary: end_at
    });
  #end date
  
  buildStrat: (filter, layer) ->
    strat = new OpenLayers.Strategy.Filter({
      layer: layer,
      autoActivate: true
    });
    # handle issue with openlayers2.12 cache being initialized as null
    strat.cache = []
    strat
  #end build
#end StratBuilder