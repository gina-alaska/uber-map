class @StyleBuilder
  ruleBuilders: {
    "between": (field, values, style) ->
      new OpenLayers.Rule({
        filter: new OpenLayers.Filter.Comparison({
          type: OpenLayers.Filter.Comparison.BETWEEN,
          property: field,
          lowerBoundary: values[0],
          upperBoundary: values[1]
        }),
        symbolizer: style
      })
      
    ">": (field, values, style) ->
      new OpenLayers.Rule({
        filter: new OpenLayers.Filter.Comparison({
          type: OpenLayers.Filter.Comparison.GREATER_THAN,
          property: field,
          value: values[0]
        }),
        symbolizer: style
      })
    
    "<": (field, values, style) ->
      new OpenLayers.Rule({
        filter: new OpenLayers.Filter.Comparison({
          type: OpenLayers.Filter.Comparison.LESS_THAN,
          property: field,
          value: values[0]
        }),
        symbolizer: style
      })
    
    "=": (field, values, style) ->
      new OpenLayers.Rule({
        filter: new OpenLayers.Filter.Comparison({
          type: OpenLayers.Filter.Comparison.EQUAL_TO,
          property: field,
          value: values[0]
        }),
        symbolizer: style
      })
  }
  
  buildStyles: (config) ->
    styles = {}
    
    if config
      if config.default
        styles.default = new OpenLayers.Style(config.default)
      else
        styles.default = new OpenLayers.Style(config);        
      #end if
    
      if config.selected
        styles.select = new OpenLayers.Style(config.selected)
      # else
      #   styles.select = styles.default
        
      #end if
    #end if
    
    styles
  #end buildStyles
  
  buildRules: (config) ->
    if(config && config.length > 0)
      style_rules = for rule in config
        if typeof rule.values == Array 
          values = rule.values
        else
          values = [rule.values]
          
        @ruleBuilders[rule.handler](rule.field, values, rule.style)
      
      style_rules
    #end if
  #end buildRules
    
  build: (style, rules) ->
    return null if !style && !rules
    
    styleConfig = @buildStyles(style)
    styleConfig.default.addRules(@buildRules(rules)); 
             
    new OpenLayers.StyleMap(styleConfig)
  #end build
#end StyleBuilder