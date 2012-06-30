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
