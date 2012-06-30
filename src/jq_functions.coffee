# Start with the map page
#window.location.replace(window.location.href.split("#")[0] + "#mappage");

## fix height of content
fixContentHeight = () ->
  footer = $("div[data-role='footer']:visible")
  content = $("div[data-role='content']:visible:visible")
  viewHeight = $(window).height()
  contentHeight = viewHeight

#  if ((content.outerHeight()) == viewHeight)
  contentHeight -= (content.outerHeight() - content.height() + 1)
  content.height(contentHeight)

  if (map && map instanceof OpenLayers.Map)
    map.updateSize()
  else
    # initialize map
    init((feature) ->
      selectedFeature = feature
      $.mobile.changePage("#popup", "pop")
      initLayerList())
