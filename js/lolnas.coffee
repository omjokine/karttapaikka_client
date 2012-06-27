lolnasLayer = new OpenLayers.Layer.Markers("Lounaat (Helsinki)", {visibility:false, attribution: "<br/>Lounastiedot toimittaa <a href='http://www.lolnas.fi'><img src='./images/lolnas.png' style='margin-bottom: -8px'/></a>"})
window.map.addLayer(lolnasLayer)
iconSize = new OpenLayers.Size(21,25)

positionLonLat = (lon, lat) ->
    lonLat = new OpenLayers.LonLat(lon, lat)
    lonLat = lonLat.transform(new OpenLayers.Projection("EPSG:4326"), new OpenLayers.Projection("EPSG:900913"))
    return lonLat

window.loadRestaurants = (data) ->
    for restaurant in data.restaurants
        position = positionLonLat(restaurant.longitude, restaurant.latitude)
        icon = new OpenLayers.Icon("./images/restaurant.png",
                                  iconSize,
                                  new OpenLayers.Pixel(-(iconSize.w/2), -iconSize.h))
        marker = new OpenLayers.Marker(position, icon)
        marker.icon.imageDiv.style.cursor = 'pointer'
        lolnasLayer.addMarker(marker)
        bindPoiMarkerClick(marker, position, restaurantPopupHtml(restaurant))

disableEventsInsideBubble = (popup) ->
    # Some weird event conflicting is happening here. OpenLayers somehow overrides the events registered by rails.js with 'live' method.
    #
    # http://stackoverflow.com/questions/4036105/qx-ui-root-inline-in-an-openlayers-popup-contentdiv-button-wont-click

    popup.events.un({
      "click": popup.onclick,
      scope: popup
    })

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

bindPoiMarkerClick = (marker, position, content) ->
    markerClick = (evt) ->
        if window.openPopup
            window.openPopup.hide()

        if this.popup
            this.popup.toggle()
        else
            this.popup = new OpenLayers.Popup(null,
                                             position,
                                             new OpenLayers.Size(200,200),
                                             content, true)
            disableEventsInsideBubble(this.popup)
            window.map.addPopup(this.popup)
            this.popup.updateSize()
            this.popup.show()

        window.openPopup = this.popup

    marker.events.register("click", marker, markerClick)