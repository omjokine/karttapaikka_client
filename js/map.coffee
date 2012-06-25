map = new OpenLayers.Map 'map',
    projection: new OpenLayers.Projection("EPSG:900913")
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
        new OpenLayers.Control.ScaleLine({bottomOutUnits: 'nmi', bottomInUnits: 'm', geodesic: true, maxWidth: 300})
    ]
    layers: [
        new OpenLayers.Layer.OSM("OpenStreetMap", null, { transitionEffect: 'resize' })
        new OpenLayers.Layer.Google("Google Streets")
    ]

map.setCenter(
    new OpenLayers.LonLat(24.949779, 60.177046).transform(
        new OpenLayers.Projection("EPSG:4326"),
        map.getProjectionObject()
    ),
    11
)

# Get rid of address bar on iphone/ipod
fixSize = () ->
    window.scrollTo(0,0)
    document.body.style.height = '100%'
    if (!(/(iphone|ipod)/.test(navigator.userAgent.toLowerCase())))
        if (document.body.parentNode)
            document.body.parentNode.style.height = '100%'

setTimeout(fixSize, 700)
setTimeout(fixSize, 1500)