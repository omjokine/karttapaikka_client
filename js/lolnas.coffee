#new OpenLayers.Layer.Markers("Lounaat (Helsinki)", {visibility:false, attribution: "<br/>Lounastiedot toimittaa <a href='http://www.lolnas.fi'><img src='./images/lolnas.png' style='margin-bottom: -8px'/></a>"})
#iconSize = new OpenLayers.Size(21,25)

transformLonLat = (lon, lat) ->
    lonLat = new OpenLayers.LonLat(lon, lat)
    lonLat = lonLat.transform(new OpenLayers.Projection("EPSG:4326"), new OpenLayers.Projection("EPSG:900913"))
    return lonLat

window.loadRestaurants = (data) ->
    styleMap = new OpenLayers.StyleMap({
                    "default":new OpenLayers.Style(OpenLayers.Util.applyDefaults({
                    externalGraphic:"./images/restaurant.png",
                    graphicOpacity:1,
                    pointRadius: 14
                    }, OpenLayers.Feature.Vector.style["default"]))
                    })

    lolnasLayer = new OpenLayers.Layer.Vector(
                        "Lounaat (Helsinki)",
                        {visibility:true,
                        attribution: "<br/>Lounastiedot toimittaa <a href='http://www.lolnas.fi'><img src='./images/lolnas.png' style='margin-bottom: -8px'/></a>",
                        styleMap: styleMap})
    for restaurant in data.restaurants
        lonLat = transformLonLat(restaurant.longitude, restaurant.latitude)
        # icon = new OpenLayers.Icon("./images/restaurant.png",
        #                           iconSize,
        #                           new OpenLayers.Pixel(-(iconSize.w/2), -iconSize.h))
        marker = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.Point(lonLat.lon, lonLat.lat))
        marker.popupHtml = restaurantPopupHtml(restaurant)
        lolnasLayer.addFeatures([marker])
#        bindPoiMarkerClick(lolnasLayer, marker, lonLat, restaurantPopupHtml(restaurant))
    selectControl = new OpenLayers.Control.SelectFeature(lolnasLayer,
    {
        onSelect: onPopupFeatureSelect,
        onUnselect: onPopupFeatureUnselect
    })
    window.map.addControl(selectControl)
    selectControl.activate()
    window.map.addLayer(lolnasLayer)

onPopupClose = (evt) ->
    selectControl.unselect(selectedFeature)

onPopupFeatureSelect = (feature) ->
    alert "#{feature.popupHtml}"
    # selectedFeature = feature
    # popup = new OpenLayers.Popup.FramedCloud("chicken",
    #     feature.geometry.getBounds().getCenterLonLat(),
    #     null, feature.name, null, true, onPopupClose)
    # popup.panMapIfOutOfView = true
    # popup.autoSize = true
    # feature.popup = popup
    # popup.show()
    # window.map.addPopup(popup)

onPopupFeatureUnselect = (feature) ->
    # alert "suljettiin: #{feature.name}"
    # map.removePopup(feature.popup)
    # feature.popup.destroy()
    # feature.popup = null

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

bindPoiMarkerClick = (layer, marker, position, content) ->
    markerClick = (evt) ->
        # if window.openPopup
        #     window.openPopup.hide()
        #
        # if this.popup
        #     this.popup.toggle()
        # else
        #     this.popup = new OpenLayers.Popup(null,
        #                                      position,
        #                                      new OpenLayers.Size(200,200),
        #                                      content, true)
        #     window.map.addPopup(this.popup)
        #     this.popup.updateSize()
        #     this.popup.show()
        #
        # window.openPopup = this.popup

    layer.events.register("click", marker, markerClick)