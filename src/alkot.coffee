styleMap = new OpenLayers.StyleMap({
              "default":new OpenLayers.Style(OpenLayers.Util.applyDefaults({
              externalGraphic:"./images/alko.png"
              graphicOpacity:1
              pointRadius: 14
              }
              OpenLayers.Feature.Vector.style["default"]))
              })

alkoLayer = new OpenLayers.Layer.Vector(
              "Alkot"
              {visibility:false
              styleMap: styleMap
              })

data = $.getJSON("json/alkot.json"
  (returnData) ->
    updateAlkoLayer(returnData)
)

updateAlkoLayer = (data) ->
  for alko in data.alkos
    lonLat = transformLonLat(alko.longitude, alko.latitude)
    marker = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.Point(lonLat.lon, lonLat.lat))
    marker.attributes = {
      type: "alko"
      name: alko.name
      address: alko.address
      post_office: alko.post_office
      zip_code: alko.zip_code
      telephone: alko.telephone
      email: alko.email
      info: alko.info
    }
    alkoLayer.addFeatures([marker])

  map.addLayer(alkoLayer)

onPopupClose = (evt) ->
  selectControl.unselect(selectedFeature)

onPopupFeatureSelect = (feature) ->
  if feature.attributes.type == "restaurant"
    $.getJSON("http://www.lolnas.fi/api/restaurants/#{feature.attributes.restaurant_id}.json?callback=?"
      (returnData) ->
        updateRestaurantPopUp(returnData)
    )
  else
    $("#popUpContainer #popUpHeader").html("#{alkoPopUpHeaderHtml(feature)}")
    $("#popUpContainer #popUpContent").html("#{alkoPopUpContentHtml(feature)}")
    $("#popUpContainer #popUpFooter").html("")
    $("#popUpContainer").popup("open")

onPopupAlkoUnselect = (alko) ->

alkoPopUpHeaderHtml = (alko) ->
  "#{alko.attributes.name}"

alkoPopUpContentHtml = (alko) ->
  html = "#{alko.attributes.address}<br/>#{alko.attributes.zip_code} #{alko.attributes.post_office}<br/>"
  html += "Puhelin: #{alko.attributes.telephone}<br/>"
  html += "Sähköposti: <a href='mailto:#{alko.attributes.email}'>#{alko.attributes.email}</a><br/>"
  html += "<div id='alkoInfo'>#{alko.attributes.info}</div>"

  return html