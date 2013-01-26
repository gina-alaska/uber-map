# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

class @Map
  init: (projection) =>
    $(document).ready(() =>
      @uber = new UberMap
      @uber.init(projection)  
      
      @initControls()
      @initLayers()
      
      $('#map-identify').popover(
        placement: 'right'
        title: 'Identify Tool'
        content: 'Activate this tool to show additional information when clicking on points in the map'
        trigger: 'hover'
      )
      
      $('#map-identify').popover('show')
      
      setTimeout(() ->
        $('#map-identify').popover('hide')
      , 15000)
      
    
      $(document).on('click', '.legend input[type="checkbox"]', (e) =>
        name = $(e.target).data('slug')
        checked = $(e.target).attr('checked')
        @toggleLayer(name, checked)
      )
      
      $('#sidebar .collapse').on 'hidden', -> 
        $(this).parent().find('.accordion-heading i.icon-chevron-up').removeClass('icon-chevron-up').addClass('icon-chevron-down')
      $('#sidebar .collapse').on 'shown', -> 
        $(this).parent().find('.accordion-heading i.icon-chevron-down').removeClass('icon-chevron-down').addClass('icon-chevron-up')
      
    
      $('#map-tools a').tooltip({ placement: 'bottom' })
    )
  #end init
  
  initControls: -> 
    @feed_select_control = new OpenLayers.Control.SelectFeature([], {
      onSelect: @onFeatureSelect,
      autoActivate: false
    })
    @uber.map.addControl(@feed_select_control)
    
    $(document).on('click', '#map-identify', (e) =>
      if $(e.currentTarget).hasClass('active')
        @feed_select_control.activate()
      else
        @feed_select_control.deactivate()
      #end if
    );
  #end initControls
  
  initLayers: =>
    layers = []
    for checkbox in $('.style input[type="checkbox"]')
      do (checkbox) =>
        feeds = new LayerFeed(@uber.map.projection, $(checkbox).data('projection'))
        filters = new FilterBuilder
      
        @spinner("#style-#{$(checkbox).data('slug')} .spinner")
      
        request = $.get($(checkbox).data('url'), (data) =>
          try
            layer = feeds.createLayer(data)
            layer.setVisibility($(checkbox).attr('checked'))
            @uber.map.addLayer layer
            layers.push layer
            @feed_select_control.setLayer(layers)
          catch err
            @uber.message "Error while reading features for #{$(checkbox).data('slug')}"        
        )
      
        request.error =>
          @spinner("#style-#{$(checkbox).data('slug')} .spinner", true)
          @uber.message "Error while downloading features for #{$(checkbox).data('slug')}"        
          
        request.complete =>
          @spinner("#style-#{$(checkbox).data('slug')} .spinner", true)
    
  
  onFeatureSelect: (feature) =>
    slug = feature.layer.name
    
    $.get "/layers/#{slug}/template", { attributes: feature.attributes }, (content) =>
      popup = new OpenLayers.Popup.FramedCloud("popup-"+feature.id, 
         feature.geometry.getBounds().getCenterLonLat(),
         null,
         content, null, true);
      @uber.map.addPopup(popup)
      @feed_select_control.unselectAll()        
    
    # content = for key, value of feature.attributes when value isnt null
    #   "<div class=\"item item-#{key}\"><label>#{key.replace(/_/g, ' ')}:</label> #{value}</div>"
    # #end for
    #   
    # content = '<div class="feature-popup-content">' + content.join('') + '</div>'
    #       
    # popup = new OpenLayers.Popup.FramedCloud("popup-"+feature.id, 
    #    feature.geometry.getBounds().getCenterLonLat(),
    #    null,
    #    content, null, true);
    # @uber.map.addPopup(popup)
    # @feed_select_control.unselectAll()  
  
  spinner: (el, disable = false) ->
    if disable
      config = false
    else
      config = {
        lines: 11,            # The number of lines to draw
        length: 4,            # The length of each line
        width: 2,             # The line thickness
        radius: 6,            # The radius of the inner circle
        rotate: 0,            # The rotation offset
        color: '#FFF',        # #rgb or #rrggbb
        speed: 1.4,           # Rounds per second
        trail: 68,            # Afterglow percentage
        shadow: true,         # Whether to render a shadow
        hwaccel: false,       # Whether to use hardware acceleration
        className: 'spinner', # The CSS class to assign to the spinner
        zIndex: 2e9,          # The z-index (defaults to 2000000000)
        top: 'auto',          # Top position relative to parent in px
        left: 'auto'          # Left position relative to parent in px
      }
    $(el).spin(config)
  #end spinner
  
  toggleLayer: (name, visible) ->
    layers = @uber.map.getLayersByName(name)
    layers[0].setVisibility(visible) if layers[0]
  #end toggleLayer
  
#end class @Map