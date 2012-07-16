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
    marker.attributes = {
      type: "restaurant"
      restaurant_id: restaurant.id
    }
    lolnasLayer.addFeatures([marker])
  # selectControl = new OpenLayers.Control.SelectFeature(lolnasLayer
  # {
  #   id: "lolnas-select-control"
  #   onSelect: onPopupFeatureSelect
  #   onUnselect: onPopupFeatureUnselect
  # })
  # map.addControl(selectControl)
  # selectControl.activate()
  map.addLayer(lolnasLayer)

onPopupClose = (evt) ->
  selectControl.unselect(selectedFeature)

# onPopupFeatureSelect = (feature) ->
#   $.getJSON("http://www.lolnas.fi/api/restaurants/#{feature.attributes.restaurant_id}.json?callback=?"
#     (returnData) ->
#       updatePopUp(returnData)
#   )

updateRestaurantPopUp = (restaurant_json) ->
  restaurant = restaurant_json.restaurant
  $("#popUpContainer #popUpHeader").html("#{restaurantPopUpHeaderHtml(restaurant)}")
  $("#popUpContainer #popUpContent").html("#{restaurantPopUpContentHtml(restaurant)}")
  $("#popUpContainer #popUpFooter").html("#{restaurantPopUpFooterHtml(restaurant)}")
  $("#popUpContainer").popup("open")

onPopupFeatureUnselect = (feature) ->

restaurantPopUpHeaderHtml = (restaurant) ->
  if restaurant.url
    html = "<a href='#{restaurant.url}' target='_new'>#{restaurant.name}</a>"
  else
    html = "#{restaurant.name}"

restaurantPopUpFooterHtml = (restaurant) ->
  html = '<div class="data-provider">'
  html += 'Tämän ravintolan lounastiedot toimitti '
  if restaurant.data_provider_title
    html += "<a href='#{restaurant.data_provider_url}' target='_new'>" if restaurant.data_provider_url
    html += restaurant.data_provider_title
    html += '</a>' if restaurant.data_provider_url
  else
    html += 'anonyymi'
  html += '.</div>'

restaurantPopUpContentHtml = (restaurant) ->
  html = ""
  if restaurant.lunches.length == 0
    html += "Ravintolan lounastiedot eivät ole saatavilla."
  else
    html += '<div class="menu">'
    html += htmlLunch(lunch) for lunch in restaurant.lunches
    html += '</div>'

htmlLunch = (lunch) ->
  html = ''
  html += lunch.title
  if lunch.price
    html += '&nbsp;<strong>'
    html += lunch.price.toFixed(2).toString().replace(/\./, ',')
    html += '&nbsp;&euro;</strong>'
  html += '<br/>'