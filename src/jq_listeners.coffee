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

$("#aerialLayer").live('click', () ->
                        layer = mmlIlmakuvat
                        layer.setVisibility(!layer.getVisibility())
                        )
