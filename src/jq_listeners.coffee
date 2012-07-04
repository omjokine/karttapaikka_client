$("#locate").live('click', () ->
                    control = map.getControlsBy("id", "locate-control")[0]
                    if (control.active)
                      control.getCurrentLocation()
                    else
                      control.activate()
                      # jotain outoa täällä, select-feature-controller täytyy alustaa uusiksi
                      controlz = map.getControlsBy("id", "lolnas-select-control")[0]
                      controlz.setLayer(lolnasLayer) if controlz
                    )

$("#lolnasLayer").live('change', () ->
                        lolnasLayer.setVisibility($(this).is(':checked'))
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

