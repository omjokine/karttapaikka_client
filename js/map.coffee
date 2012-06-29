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

getTileURL = (bounds) ->
    z = this.map.getZoom() - this.map.getZoomForResolution(78271.516953125) + 1
    res = this.map.getResolution()
    x = Math.round ((bounds.left - this.maxExtent.left) / (res * this.tileSize.w))
    ymax = 1 << z
    y = Math.round ((this.maxExtent.top - bounds.top) / (res * this.tileSize.h))
    y = ymax-y-1

    path = z + "/" + x + "/" + y + "." + this.type
    url = this.url
    if (url instanceof Array)
        url = this.selectUrl(path, url)

    return url + path

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

mapQuest = new OpenLayers.Layer.OSM("MapQuest",
                                   ["http://otile1.mqcdn.com/tiles/1.0.0/osm/${z}/${x}/${y}.png",
                                    "http://otile2.mqcdn.com/tiles/1.0.0/osm/${z}/${x}/${y}.png",
                                    "http://otile3.mqcdn.com/tiles/1.0.0/osm/${z}/${x}/${y}.png",
                                    "http://otile4.mqcdn.com/tiles/1.0.0/osm/${z}/${x}/${y}.png"]
                                    {
                                    transitionEffect: 'resize'
                                    attribution: "Data, imagery and map information provided by <a href='http://www.mapquest.com/'  target='_blank'>MapQuest</a>, <a href='http://www.openstreetmap.org/' target='_blank'>Open Street Map</a> and contributors, <a href='http://creativecommons.org/licenses/by-sa/2.0/' target='_blank'>CC-BY-SA</a>  <img src='http://developer.mapquest.com/content/osm/mq_logo.png' border='0'>"
                                    })

bingAerial = new OpenLayers.Layer.Bing({
                                      name: "Bing - Aerial",
                                      key: bingKey,
                                      type: "Aerial",
                                      transitionEffect: 'resize'})
bingHybrid = new OpenLayers.Layer.Bing({
                                      name: "Bing - Hybrid",
                                      key: bingKey, type: "AerialWithLabels",
                                      transitionEffect: 'resize'})
bingRoad = new OpenLayers.Layer.Bing({
                                     name: "Bing - Road",
                                     key: bingKey, type: "Road",
                                     transitionEffect: 'resize'})

mmlMaastoKartat = new OpenLayers.Layer.XYZ("Maanmittauslaitos - Maastokartat",
                                           "http://tiles.kartat.kapsi.fi/peruskartta/${z}/${x}/${y}.png",
                                           {sphericalMercator: true,
                                           attribution:"<br/>Maastokartat ja ilmakuvat &copy; <a class='attribution' href='http://maanmittauslaitos.fi/'>MML</a>, jakelu <a class='attribution' href='http://kartat.kapsi.fi/'>Kapsi ry</a>",
                                           transitionEffect: 'resize'})

osmCycle = new OpenLayers.Layer.OSM("OpenStreetMap - Cycle",
                                   ["http://a.tile.opencyclemap.org/cycle/${z}/${x}/${y}.png",
                                   "http://b.tile.opencyclemap.org/cycle/${z}/${x}/${y}.png",
                                   "http://c.tile.opencyclemap.org/cycle/${z}/${x}/${y}.png"],
                                   { transitionEffect: 'resize' })
osmStandard = new OpenLayers.Layer.OSM("OpenStreetMap - Standard",
                                      null,
                                      {transitionEffect: 'resize'})
osmTransport = new OpenLayers.Layer.OSM("OpenStreetMap - Transport",
                                       ["http://a.tile2.opencyclemap.org/transport/${z}/${x}/${y}.png",
                                       "http://b.tile2.opencyclemap.org/transport/${z}/${x}/${y}.png",
                                       "http://c.tile2.opencyclemap.org/transport/${z}/${x}/${y}.png"],
                                       {transitionEffect: 'resize'})

oviSatellite = new OpenLayers.Layer.XYZ("Ovi Maps - Satellite",
                                       ["http://e.maptile.maps.svc.ovi.com/maptiler/maptile/newest/hybrid.day/${z}/${x}/${y}/256/png8",
                                       "http://f.maptile.maps.svc.ovi.com/maptiler/maptile/newest/hybrid.day/${z}/${x}/${y}/256/png8"],
                                       {
                                       transitionEffect: 'resize',
                                       sphericalMercator: true,
                                       numZoomLevels: 21 })
oviStreets = new OpenLayers.Layer.XYZ("Ovi Maps - Street",
                                     ["http://a.maptile.maps.svc.ovi.com/maptiler/maptile/newest/normal.day/${z}/${x}/${y}/256/png8",
                                     "http://b.maptile.maps.svc.ovi.com/maptiler/maptile/newest/normal.day/${z}/${x}/${y}/256/png8"],
                                     {
                                     transitionEffect: 'resize',
                                     sphericalMercator: true,
                                     numZoomLevels: 21 })
oviTransit = new OpenLayers.Layer.XYZ("Ovi Maps - Transit",
                                     ["http://c.maptile.maps.svc.ovi.com/maptiler/maptile/newest/normal.day.transit/${z}/${x}/${y}/256/png8",
                                     "http://d.maptile.maps.svc.ovi.com/maptiler/maptile/newest/normal.day.transit/${z}/${x}/${y}/256/png8"],
                                     {
                                     transitionEffect: 'resize',
                                     sphericalMercator: true,
                                     numZoomLevels: 21 })

# GetMLLXYZ-lolli, koska Bing kartat antaa väärän zoomlevelin
mmlIlmakuvat = new OpenLayers.Layer.XYZ("Maanmittauslaitos - Ilmakuvat",
                                       "http://tiles.kartat.kapsi.fi/ortokuva/${z}/${x}/${y}.png",
                                       {
                                       getXYZ: getMLLXYZ,
                                       minScale: 100000,
                                       isBaseLayer: false,
                                       visibility: false,
                                       attribution:"<br/>Maastokartat ja ilmakuvat &copy; <a class='attribution' href='http://maanmittauslaitos.fi/'>MML</a>, jakelu <a class='attribution' href='http://kartat.kapsi.fi/'>Kapsi ry</a>"
                                       })
trafiMerikartta = new OpenLayers.Layer.XYZ("Liikennevirasto - Merikartta"
                      "http://mapserver.sailmate.fi/fi/images/"
                      {
                      'type': 'png'
                      'getURL':getTileURL
                      isBaseLayer: false
                      transparent: true
                      numZoomLevels: 16
                      visibility: false
                      attribution:"<br/>Merikartat &copy; <a class='attribution' href='http://liikennevirasto.fi/'>Liikennevirasto</a>, jakelu <a class='attribution' href='http://www.sailmate.fi/'><img src='./images/sailmate.png' style='margin-bottom: -4px'/></a>"
                      })

window.aerialLayer = trafiMerikartta

layerPanel = new OpenLayers.Control.Panel({
                displayClass: "layerPanel"
                autoActivate: true
                })

baseLayerButton = new OpenLayers.Control({
                      type: OpenLayers.Control.TYPE_TOOL
                      displayClass: "aerialButton"
                      eventListeners: {
                          activate: () ->
                              if (mapQuest)
                                  map.setBaseLayer(mapQuest)
                      }
                      })

maastoButton = new OpenLayers.Control({
                  type: OpenLayers.Control.TYPE_TOOL
                  displayClass: "aerialButton"
                  eventListeners: {
                      activate: () ->
                          if (mmlMaastoKartat)
                              map.setBaseLayer(mmlMaastoKartat)
                  }
                  })

layerPanel.addControls([baseLayerButton, maastoButton])

geoLocateVector = new OpenLayers.Layer.Vector('geoLocate');

#zoomPanel = new OpenLayers.Control.ZoomPanel()
geoLocateControl = new OpenLayers.Control.Geolocate(
                      {
                      id: 'locate-control'
                      type: OpenLayers.Control.TYPE_TOGGLE
                      geolocationOptions:
                          {
                          enableHighAccuracy: false
                          maximumAge: 0
                          timeout: 7000
                          }
                      eventListeners:
                          {
                          activate: () ->
                              map.addLayer(geoLocateVector)
                          deactivate: () ->
                              map.removeLayer(geoLocateVector);
                              geoLocateVector.removeAllFeatures();
                          locationupdated: (e) ->
                              geoLocateVector.removeAllFeatures();
                              geoLocateVector.addFeatures([
                                  new OpenLayers.Feature.Vector(e.point, null,
                                      {
                                      graphicName: 'cross'
                                      strokeColor: '#f00'
                                      strokeWidth: 2
                                      fillOpacity: 0
                                      pointRadius: 10
                                      })
                                  new OpenLayers.Feature.Vector(
                                      OpenLayers.Geometry.Polygon.createRegularPolygon(
                                          new OpenLayers.Geometry.Point(e.point.x, e.point.y),
                                          e.position.coords.accuracy / 2, 50, 0
                                      ), null,
                                      {
                                      fillOpacity: 0.1
                                      fillColor: '#000'
                                      strokeColor: '#f00'
                                      strokeOpacity: 0.6
                                      })
                              ])
                          }
                      })
#zoomPanel.addControls([geoLocateControl])

map = new OpenLayers.Map 'map',
    projection: defaultProjection
    controls: [
        new OpenLayers.Control.Zoom()
        new OpenLayers.Control.Attribution()
        new OpenLayers.Control.TouchNavigation({
            dragPanOptions: {
                enableKinetic: true
            }
        })
        layerPanel
        geoLocateControl
#        new OpenLayers.Control.ScaleLine({maxWidth: 300, bottomOutUnits: '', bottomInUnits: ''})
    ]
    layers: [
        bingAerial
        mapQuest
        mmlIlmakuvat
    ]
    eventListeners: { "moveend": storeMapPosition }

map.setCenter(new OpenLayers.LonLat(mapPosition.longitude, mapPosition.latitude), mapPosition.zoom)
map.setBaseLayer(mapQuest)

# Get rid of address bar on iphone/ipod
fixSize = () ->
    window.scrollTo(0,0)
    document.body.style.height = '100%'
    if (!(/(iphone|ipod)/.test(navigator.userAgent.toLowerCase())))
        if (document.body.parentNode)
            document.body.parentNode.style.height = '100%'

setTimeout(fixSize, 700)
setTimeout(fixSize, 1500)

window.map = map