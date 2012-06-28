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
  #end only
  
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