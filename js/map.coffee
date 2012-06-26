default_projection = new OpenLayers.Projection("EPSG:900913")

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
        new OpenLayers.Layer.Google("Google Streets", {'sphericalMercator': true, numZoomLevels: 19}),
        new OpenLayers.Layer.XYZ("Maanmittauslaitos - Maastokartat",
                                 "http://tiles.kartat.kapsi.fi/peruskartta/${z}/${x}/${y}.png",
                                 {sphericalMercator: true, attribution:"<br/>Maastokartat ja ilmakuvat: <a class='attribution' href='http://maanmittauslaitos.fi/'>MML</a>"})
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