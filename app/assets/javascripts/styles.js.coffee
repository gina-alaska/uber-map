class @StyleBuilder
  
  ruleBuilders: {
    # clamp values between 0 and 1.0
    clamp: (v) ->
      return Math.max(0, Math.min(1, parseFloat(v)))
    #end clamp
    
    "ColorRamp-3": (field, values, style, features) ->
      min = max = null
      
      for f in features
        min = parseFloat(f.attributes[field]) if min > parseFloat(f.attributes[field]) || min == null
        max = parseFloat(f.attributes[field]) if max < parseFloat(f.attributes[field]) || max == null
      #end for
      
      t = max - min
      
      for f in features
        x = (parseFloat(f.attributes[field] - min))/t
        xg = x - 1
        xb = x - 0.5
        r = parseInt(-255*@clamp(x*x) + 255)
        g = parseInt(-255*@clamp(xg*xg) + 255)
        b = parseInt(-255*@clamp(xb*xb) + 255)
        
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
    #end 3colorramp
      
    "ColorRamp-3Low": (field, values, style, features) ->
      min = max = null
      total = 0
      
      for f in features
        min = parseFloat(f.attributes[field]) if min > parseFloat(f.attributes[field]) || min == null
        max = parseFloat(f.attributes[field]) if max < parseFloat(f.attributes[field]) || max == null
        total = total + parseFloat(f.attributes[field])
      #end for

      t = max - min      
      avg = total / features.length / t * 100
      for f in features
        x = (parseFloat(f.attributes[field])-min)/t
        xg = x
        xb = x - 0.5
        r = parseInt(255*@clamp(avg*x))
        g = parseInt(255*@clamp(xg))
        b = parseInt(255*(@clamp(avg*xb*xb)))
        
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
    #end 2colorramp
    
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
      else
        styles.select = styles.default
      #end if
      
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