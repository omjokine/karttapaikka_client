$("#locate").live('click', () ->
                    control = map.getControlsBy("id", "locate-control")[0]
                    if (control.active)
                      control.getCurrentLocation()
                    else
                      control.activate()
                    )

$("#lolnasLayer").live('click', () ->
                        layer = lolnasLayer
                        layer.setVisibility(!layer.getVisibility())
                        )

$("#mapSelect").live('change', () ->
                      value = $(this).val()
                      eval("map.setBaseLayer(#{value})")
                      )

$("#plus").live('click', () -> map.zoomIn())

$("#minus").live('click', () -> map.zoomOut())

# fix the content height AFTER jQuery Mobile has rendered the map page
#$('#mappage').live('pageshow', () ->  map.render($('#map')))
#$(window).bind("orientationchange resize pageshow", fixContentHeight)

