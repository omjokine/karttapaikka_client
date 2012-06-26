default_projection = new OpenLayers.Projection("EPSG:900913")

bing_key = "AjiRFAOxAb5Z01PMW3EwdUrCjDhN88QKPA3OfFmUuheW4ByTUZ9XPySvAv50RUpR"

map = new OpenLayers.Map 'map',
    projection: default_projection,
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
        new OpenLayers.Layer.Bing({name: "Bing - Road", key: bing_key, type: "Road", transitionEffect: 'resize' })
        new OpenLayers.Layer.Bing({name: "Bing - Aerial", key: bing_key, type: "Aerial", transitionEffect: 'resize'})
        new OpenLayers.Layer.Bing({name: "Bing - Hybrid", key: bing_key, type: "AerialWithLabels", transitionEffect: 'resize'})
        new OpenLayers.Layer.Google("Google - Streets", {'sphericalMercator': true, numZoomLevels: 19})
        new OpenLayers.Layer.Google("Google - Terrain", {type: google.maps.MapTypeId.TERRAIN, 'sphericalMercator': true, numZoomLevels: 19})
        new OpenLayers.Layer.Google("Google - Satellite", {type: google.maps.MapTypeId.SATELLITE, 'sphericalMercator': true, numZoomLevels: 19})
        new OpenLayers.Layer.Google("Google - Hybrid", {type: google.maps.MapTypeId.HYBRID, 'sphericalMercator': true, numZoomLevels: 19})
        new OpenLayers.Layer.XYZ("Maanmittauslaitos - Maastokartat",
                                 "http://tiles.kartat.kapsi.fi/peruskartta/${z}/${x}/${y}.png",
                                 {sphericalMercator: true, attribution:"<br/>Maastokartat ja ilmakuvat: <a class='attribution' href='http://maanmittauslaitos.fi/'>MML</a>", transitionEffect: 'resize'})
        new OpenLayers.Layer.XYZ("Ovi Maps - Street", ["http://a.maptile.maps.svc.ovi.com/maptiler/maptile/newest/normal.day/${z}/${x}/${y}/256/png8",
                                            "http://b.maptile.maps.svc.ovi.com/maptiler/maptile/newest/normal.day/${z}/${x}/${y}/256/png8"],
                                            { transitionEffect: 'resize', sphericalMercator: true, numZoomLevels: 21 })
        new OpenLayers.Layer.XYZ("Ovi Maps - Transit", ["http://c.maptile.maps.svc.ovi.com/maptiler/maptile/newest/normal.day.transit/${z}/${x}/${y}/256/png8",
                                             "http://d.maptile.maps.svc.ovi.com/maptiler/maptile/newest/normal.day.transit/${z}/${x}/${y}/256/png8"],
                                            { transitionEffect: 'resize', sphericalMercator: true, numZoomLevels: 21 })
        new OpenLayers.Layer.XYZ("Ovi Maps - Satellite", ["http://e.maptile.maps.svc.ovi.com/maptiler/maptile/newest/hybrid.day/${z}/${x}/${y}/256/png8",
                                               "http://f.maptile.maps.svc.ovi.com/maptiler/maptile/newest/hybrid.day/${z}/${x}/${y}/256/png8"],
                                            { transitionEffect: 'resize', sphericalMercator: true, numZoomLevels: 21 })
        new OpenLayers.Layer.XYZ("Maanmittauslaitos - Ilmakuvat",
                                 "http://tiles.kartat.kapsi.fi/ortokuva/${z}/${x}/${y}.png",
                                 {sphericalMercator: true, minScale: 100000, isBaseLayer: false, visibility: false, attribution:"<br/>Maastokartat ja ilmakuvat: <a class='attribution' href='http://maanmittauslaitos.fi/'>MML</a>"})
    ]
    center: new OpenLayers.LonLat(24.949779, 60.177046).transform(
                new OpenLayers.Projection("EPSG:4326"),
                default_projection
            )
    zoom: 11

# Get rid of address bar on iphone/ipod
fixSize = () ->
    window.scrollTo(0,0)
    document.body.style.height = '100%'
    if (!(/(iphone|ipod)/.test(navigator.userAgent.toLowerCase())))
        if (document.body.parentNode)
            document.body.parentNode.style.height = '100%'

setTimeout(fixSize, 700)
setTimeout(fixSize, 1500)