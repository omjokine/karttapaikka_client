defaultProjection = new OpenLayers.Projection("EPSG:900913")
bingKey = "AjiRFAOxAb5Z01PMW3EwdUrCjDhN88QKPA3OfFmUuheW4ByTUZ9XPySvAv50RUpR"

storeMapPosition = (event) ->
    lonlat = event.object.getCenter();
    zoomLevel = event.object.getZoom();

    mapPosition = {
      longitude: lonlat.lon,
      latitude: lonlat.lat,
      zoom: zoomLevel
    }

    $.JSONCookie('position', mapPosition, {expires: 30})

loadMapPosition = () ->
    position = $.JSONCookie('position')
    position = {longitude: 2777381.0927341, latitude: 8439319.5947809, zoom: 11} unless position.longitude
    return position

mapPosition = loadMapPosition()

# getTileURL = (bounds) ->
#     z = this.map.getZoom() - this.map.getZoomForResolution(78271.516953125) + 1
#     res = this.map.getResolution()
#     x = Math.round ((bounds.left - this.maxExtent.left) / (res * this.tileSize.w))
#     ymax = 1 << z
#     y = Math.round ((this.maxExtent.top - bounds.top) / (res * this.tileSize.h))
#     y = ymax-y-1
#
#     path = z + "/" + x + "/" + y + "." + this.type
#     url = this.url
#     if (url instanceof Array)
#         url = this.selectUrl(path, url)
#
#     return url + path

# Bing antaa väärän zoomlevelin, häkki toistaiseksi:
getMLLXYZ = (bounds) ->
    res = this.getServerResolution()
    x = Math.round((bounds.left - this.maxExtent.left) /(res * this.tileSize.w))
    y = Math.round((this.maxExtent.top - bounds.top) /(res * this.tileSize.h))
    z = this.map.getZoom() - this.map.getZoomForResolution(78271.516953125) + 1

    if (this.wrapDateLine)
        limit = Math.pow(2, z);
        x = ((x % limit) + limit) % limit;

    return {'x': x, 'y': y, 'z': z};

map = new OpenLayers.Map 'map',
    projection: defaultProjection
    controls: [
        new OpenLayers.Control.PanZoomBar(),
        new OpenLayers.Control.Navigation(),
        new OpenLayers.Control.LayerSwitcher(),
        new OpenLayers.Control.Attribution(),
        new OpenLayers.Control.TouchNavigation({
            dragPanOptions: {
                enableKinetic: true
            }
        }),
        new OpenLayers.Control.ScaleLine({maxWidth: 300, bottomOutUnits: '', bottomInUnits: ''})
    ]
    layers: [
        new OpenLayers.Layer.OSM("OpenStreetMap", null, { transitionEffect: 'resize' })
        new OpenLayers.Layer.Bing({name: "Bing - Road", key: bingKey, type: "Road", transitionEffect: 'resize'})
        new OpenLayers.Layer.Bing({name: "Bing - Aerial", key: bingKey, type: "Aerial", transitionEffect: 'resize'})
        new OpenLayers.Layer.Bing({name: "Bing - Hybrid", key: bingKey, type: "AerialWithLabels", transitionEffect: 'resize'})
        new OpenLayers.Layer.Google("Google - Streets", {'sphericalMercator': true, numZoomLevels: 19})
        new OpenLayers.Layer.Google("Google - Terrain", {type: google.maps.MapTypeId.TERRAIN, 'sphericalMercator': true, numZoomLevels: 19})
        new OpenLayers.Layer.Google("Google - Satellite", {type: google.maps.MapTypeId.SATELLITE, 'sphericalMercator': true, numZoomLevels: 19})
        new OpenLayers.Layer.Google("Google - Hybrid", {type: google.maps.MapTypeId.HYBRID, 'sphericalMercator': true, numZoomLevels: 19})
        new OpenLayers.Layer.XYZ("Maanmittauslaitos - Maastokartat",
                                 "http://tiles.kartat.kapsi.fi/peruskartta/${z}/${x}/${y}.png",
                                 {sphericalMercator: true, attribution:"<br/>Maastokartat ja ilmakuvat &copy; <a class='attribution' href='http://maanmittauslaitos.fi/'>MML</a>, jakelu <a class='attribution' href='http://kartat.kapsi.fi/'>Kapsi ry</a>", transitionEffect: 'resize'})
        new OpenLayers.Layer.XYZ("Ovi Maps - Street", ["http://a.maptile.maps.svc.ovi.com/maptiler/maptile/newest/normal.day/${z}/${x}/${y}/256/png8",
                                            "http://b.maptile.maps.svc.ovi.com/maptiler/maptile/newest/normal.day/${z}/${x}/${y}/256/png8"],
                                            { transitionEffect: 'resize', sphericalMercator: true, numZoomLevels: 21 })
        new OpenLayers.Layer.XYZ("Ovi Maps - Transit", ["http://c.maptile.maps.svc.ovi.com/maptiler/maptile/newest/normal.day.transit/${z}/${x}/${y}/256/png8",
                                             "http://d.maptile.maps.svc.ovi.com/maptiler/maptile/newest/normal.day.transit/${z}/${x}/${y}/256/png8"],
                                            { transitionEffect: 'resize', sphericalMercator: true, numZoomLevels: 21 })
        new OpenLayers.Layer.XYZ("Ovi Maps - Satellite", ["http://e.maptile.maps.svc.ovi.com/maptiler/maptile/newest/hybrid.day/${z}/${x}/${y}/256/png8",
                                               "http://f.maptile.maps.svc.ovi.com/maptiler/maptile/newest/hybrid.day/${z}/${x}/${y}/256/png8"],
                                            { transitionEffect: 'resize', sphericalMercator: true, numZoomLevels: 21 })

        # GetMLLXYZ-lolli, koska Bing kartat antaa väärän zoomlevelin
        new OpenLayers.Layer.XYZ("Maanmittauslaitos - Ilmakuvat",
                                 "http://tiles.kartat.kapsi.fi/ortokuva/${z}/${x}/${y}.png",
                                 { getXYZ: getMLLXYZ, minScale: 100000, isBaseLayer: false, visibility: false, attribution:"<br/>Maastokartat ja ilmakuvat &copy; <a class='attribution' href='http://maanmittauslaitos.fi/'>MML</a>, jakelu <a class='attribution' href='http://kartat.kapsi.fi/'>Kapsi ry</a>"})
        # new OpenLayers.Layer.TMS("Liikennevirasto - Merikartta",
        #                          "http://mapserver.sailmate.fi/fi/images/",
        #                          { 'type': 'png', 'getURL':getTileURL, isBaseLayer: false, transparent: true, numZoomLevels: 16, visibility: false})
    ]
    eventListeners: { "moveend": storeMapPosition }

map.setCenter(new OpenLayers.LonLat(mapPosition.longitude, mapPosition.latitude), mapPosition.zoom)

# Get rid of address bar on iphone/ipod
fixSize = () ->
    window.scrollTo(0,0)
    document.body.style.height = '100%'
    if (!(/(iphone|ipod)/.test(navigator.userAgent.toLowerCase())))
        if (document.body.parentNode)
            document.body.parentNode.style.height = '100%'

setTimeout(fixSize, 700)
setTimeout(fixSize, 1500)