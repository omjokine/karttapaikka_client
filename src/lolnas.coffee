transformLonLat = (lon, lat) ->
  lonLat = new OpenLayers.LonLat(lon, lat)
  lonLat = lonLat.transform(new OpenLayers.Projection("EPSG:4326"), new OpenLayers.Projection("EPSG:900913"))
  return lonLat

styleMap = new OpenLayers.StyleMap({
              "default":new OpenLayers.Style(OpenLayers.Util.applyDefaults({
              externalGraphic:"./images/restaurant.png"
              graphicOpacity:1
              pointRadius: 14
              }
              OpenLayers.Feature.Vector.style["default"]))
              })

lolnasLayer = new OpenLayers.Layer.Vector(
                "Lounaat (Helsinki)",
                {visibility:false
                attribution: "<br/>Lounastiedot toimittaa <a href='http://www.lolnas.fi'><img src='./images/lolnas.png' style='margin-bottom: -8px'/></a>"
                styleMap: styleMap
                })

window.loadRestaurants = (data) ->
  for restaurant in data.restaurants
    lonLat = transformLonLat(restaurant.longitude, restaurant.latitude)
    marker = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.Point(lonLat.lon, lonLat.lat))
    marker.restaurant_id = restaurant.id
    marker.name = restaurant.name
    lolnasLayer.addFeatures([marker])
  selectControl = new OpenLayers.Control.SelectFeature(lolnasLayer
  "lolnas-select-control"
  {
    onSelect: onPopupFeatureSelect,
    onUnselect: onPopupFeatureUnselect
  })
  map.addControl(selectControl)
  selectControl.activate()
  map.addLayer(lolnasLayer)

onPopupClose = (evt) ->
  selectControl.unselect(selectedFeature)

onPopupFeatureSelect = (feature) ->
  $.getJSON("http://www.lolnas.fi/api/restaurants/#{feature.restaurant_id}.json?callback=?"
    (returnData) ->
      updatePopUp(returnData)
  )

updatePopUp = (restaurant_json) ->
  popupHtml = restaurantPopupHtml(restaurant_json.restaurant)
  $("#popUpContainer p").html("#{popupHtml}")
  $("#popUpContainer").popup("open")

onPopupFeatureUnselect = (feature) ->

htmlLunch = (lunch) ->
  html = ''
  html += lunch.title
  if lunch.price
    html += '&nbsp;<strong>'
    html += lunch.price.toFixed(2).toString().replace(/\./, ',')
    html += '&nbsp;&euro;</strong>'
  html += '<br />'
  return html

restaurantPopupHtml = (restaurant) ->
  html = ""
  if restaurant.url
    html += "<h1><a href='#{restaurant.url}'>#{restaurant.name}</a></h1><hr/>"
  else
    html += "<h1>#{restaurant.name}</h1><hr/>"
  if restaurant.lunches.length == 0
    html += "Ravintolan lounastiedot eivät ole saatavilla."
  else
    html += '<div class="menu">'
    html += htmlLunch(lunch) for lunch in restaurant.lunches
    html += '</div>'
    html += '<div class="data-provider">'
    html += 'Tämän ravintolan lounastiedot toimitti '
    if restaurant.data_provider_title
      html += "<a href='#{restaurant.data_provider_url}'>" if restaurant.data_provider_url
      html += restaurant.data_provider_title
      html += '</a>' if restaurant.data_provider_url
    else
      html += 'anonyymi'
    html += '.</div>'

  return html
