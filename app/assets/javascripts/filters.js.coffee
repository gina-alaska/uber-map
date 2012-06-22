class @StratBuilder
  constructor: () ->
    
  #end constructor
  
  only: (field, value) ->    
    new OpenLayers.Filter.Comparison({
      type: OpenLayers.Filter.Comparison.EQUAL_TO,
      property: field,
      value: value
    });
  #end date  
  
  date: (field, start_at, end_at, features) ->    
    if features
      for f in features
        f.attributes[field] = Date.parse(f.attributes[field])
      #end for
    #end if
    new OpenLayers.Filter.Comparison({
      type: OpenLayers.Filter.Comparison.BETWEEN,
      property: field,
      lowerBoundary: start_at,
      upperBoundary: end_at
    });
  #end date
  
  build: (filter) ->
    new OpenLayers.Strategy.Filter({
      filter: filter,
      autoActivate: true
    });
  #end build
#end StratBuilder