class @StyleBuilder
  
  ruleBuilders: {
    # clamp values between 0 and 255
    clamp: (v) ->
      return Math.max(0, Math.min(255, parseInt(v)))
    #end clamp
    
    "colorramp": (field, values, style, features) ->
      min = max = null
      
      for f in features
        min = f.attributes[field] if min > f.attributes[field] || min == null
        max = f.attributes[field] if max < f.attributes[field] || max == null
      #end for
      
      t = max - min
      
      for f in features
        x = (f.attributes[field] - 1)/t
        xg = x - 1
        xb = x - 0.5
        r = @clamp(-1020*(x*x) + 255)
        g = @clamp(-1020*(xg*xg) + 255)
        b = @clamp(-1020*(xb*xb) + 255)
        
        f.attributes['rampcolor'] = "rgba(#{r}, #{g}, #{b}, 1)}"
      #end for
      
      new OpenLayers.Rule({
        filter: new OpenLayers.Filter.Function({
          evaluate: (attributes) ->
            return true
          #end evaluate
        }),
        symbolizer: style
      })
    #end colorramp
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
    ">=": (field, values, style) ->
      new OpenLayers.Rule({
        filter: new OpenLayers.Filter.Comparison({
          type: OpenLayers.Filter.Comparison.GREATER_THAN_OR_EQUAL_TO,
          property: field,
          value: values[0]
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
      
    "<=": (field, values, style) ->
      new OpenLayers.Rule({
        filter: new OpenLayers.Filter.Comparison({
          type: OpenLayers.Filter.Comparison.LESS_THAN_OR_EQUAL_TO,
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
  
  buildRules: (config, features) ->
    if(config && config.length > 0)
      style_rules = for rule in config
        if typeof rule.values == Array 
          values = rule.values
        else
          values = [rule.values]
          
        @ruleBuilders[rule.handler](rule.field, values, rule.style, features)
        
      style_rules
    #end if
  #end buildRules
    
  build: (style, rules, features) ->
    return null if !style && !rules
    
    styleConfig = @buildStyles(style)
    styleConfig.default.addRules(@buildRules(rules, features)); 
             
    new OpenLayers.StyleMap(styleConfig)
  #end build
#end StyleBuilder