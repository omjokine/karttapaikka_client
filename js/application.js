(function() {
  var bingAerial, bingHybrid, bingKey, bingRoad, defaultProjection, fixContentHeight, geoLocateControl, geoLocateVector, getMLLXYZ, getTileURL, htmlLunch, loadMapPosition, lolnasLayer, map, mapPosition, mapQuest, mmlIlmakuvat, mmlMaastoKartat, onPopupClose, onPopupFeatureSelect, onPopupFeatureUnselect, osmCycle, osmStandard, osmTransport, oviSatellite, oviStreets, oviTransit, restaurantPopupHtml, storeMapPosition, styleMap, trafiMerikartta, transformLonLat, updatePopUp;

  fixContentHeight = function() {
    var content, contentHeight, footer, viewHeight;
    footer = $("div[data-role='footer']:visible");
    content = $("div[data-role='content']:visible:visible");
    viewHeight = $(window).height();
    contentHeight = viewHeight;
    contentHeight -= content.outerHeight() - content.height() + 1;
    content.height(contentHeight);
    if (map && map instanceof OpenLayers.Map) {
      return map.updateSize();
    } else {
      return init(function(feature) {
        var selectedFeature;
        selectedFeature = feature;
        $.mobile.changePage("#popup", "pop");
        return initLayerList();
      });
    }
  };

  $("#locate").live('click', function() {
    var control, controlz;
    control = map.getControlsBy("id", "locate-control")[0];
    if (control.active) {
      return control.getCurrentLocation();
    } else {
      control.activate();
      controlz = map.getControlsBy("id", "lolnas-select-control")[0];
      if (controlz) return controlz.setLayer(lolnasLayer);
    }
  });

  $("#lolnasLayer").live('change', function() {
    return lolnasLayer.setVisibility($(this).is(':checked'));
  });

  $("#mapSelect").live('change', function() {
    var value;
    value = $(this).val();
    return eval("map.setBaseLayer(" + value + ")");
  });

  $("#plus").live('click', function() {
    return map.zoomIn();
  });

  $("#minus").live('click', function() {
    return map.zoomOut();
  });

  transformLonLat = function(lon, lat) {
    var lonLat;
    lonLat = new OpenLayers.LonLat(lon, lat);
    lonLat = lonLat.transform(new OpenLayers.Projection("EPSG:4326"), new OpenLayers.Projection("EPSG:900913"));
    return lonLat;
  };

  styleMap = new OpenLayers.StyleMap({
    "default": new OpenLayers.Style(OpenLayers.Util.applyDefaults({
      externalGraphic: "./images/restaurant.png",
      graphicOpacity: 1,
      pointRadius: 14
    }, OpenLayers.Feature.Vector.style["default"]))
  });

  lolnasLayer = new OpenLayers.Layer.Vector("Lounaat (Helsinki)", {
    visibility: false,
    attribution: "<br/>Lounastiedot toimittaa <a href='http://www.lolnas.fi'><img src='./images/lolnas.png' style='margin-bottom: -8px'/></a>",
    styleMap: styleMap
  });

  window.loadRestaurants = function(data) {
    var lonLat, marker, restaurant, selectControl, _i, _len, _ref;
    _ref = data.restaurants;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      restaurant = _ref[_i];
      lonLat = transformLonLat(restaurant.longitude, restaurant.latitude);
      marker = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.Point(lonLat.lon, lonLat.lat));
      marker.restaurant_id = restaurant.id;
      marker.name = restaurant.name;
      lolnasLayer.addFeatures([marker]);
    }
    selectControl = new OpenLayers.Control.SelectFeature(lolnasLayer, "lolnas-select-control", {
      onSelect: onPopupFeatureSelect,
      onUnselect: onPopupFeatureUnselect
    });
    map.addControl(selectControl);
    selectControl.activate();
    return map.addLayer(lolnasLayer);
  };

  onPopupClose = function(evt) {
    return selectControl.unselect(selectedFeature);
  };

  onPopupFeatureSelect = function(feature) {
    return $.getJSON("http://www.lolnas.fi/api/restaurants/" + feature.restaurant_id + ".json?callback=?", function(returnData) {
      return updatePopUp(returnData);
    });
  };

  updatePopUp = function(restaurant_json) {
    var popupHtml;
    popupHtml = restaurantPopupHtml(restaurant_json.restaurant);
    $("#popUpContainer p").html("" + popupHtml);
    return $("#popUpContainer").popup("open");
  };

  onPopupFeatureUnselect = function(feature) {};

  htmlLunch = function(lunch) {
    var html;
    html = '';
    html += lunch.title;
    if (lunch.price) {
      html += '&nbsp;<strong>';
      html += lunch.price.toFixed(2).toString().replace(/\./, ',');
      html += '&nbsp;&euro;</strong>';
    }
    html += '<br />';
    return html;
  };

  restaurantPopupHtml = function(restaurant) {
    var html, lunch, _i, _len, _ref;
    html = "";
    if (restaurant.url) {
      html += "<h1><a href='" + restaurant.url + "'>" + restaurant.name + "</a></h1><hr/>";
    } else {
      html += "<h1>" + restaurant.name + "</h1><hr/>";
    }
    if (restaurant.lunches.length === 0) {
      html += "Ravintolan lounastiedot eivät ole saatavilla.";
    } else {
      html += '<div class="menu">';
      _ref = restaurant.lunches;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        lunch = _ref[_i];
        html += htmlLunch(lunch);
      }
      html += '</div>';
      html += '<div class="data-provider">';
      html += 'Tämän ravintolan lounastiedot toimitti ';
      if (restaurant.data_provider_title) {
        if (restaurant.data_provider_url) {
          html += "<a href='" + restaurant.data_provider_url + "'>";
        }
        html += restaurant.data_provider_title;
        if (restaurant.data_provider_url) html += '</a>';
      } else {
        html += 'anonyymi';
      }
      html += '.</div>';
    }
    return html;
  };

  defaultProjection = new OpenLayers.Projection("EPSG:900913");

  bingKey = "AjiRFAOxAb5Z01PMW3EwdUrCjDhN88QKPA3OfFmUuheW4ByTUZ9XPySvAv50RUpR";

  storeMapPosition = function(event) {
    var lonlat, mapPosition, zoomLevel;
    lonlat = event.object.getCenter();
    zoomLevel = event.object.getZoom();
    mapPosition = {
      longitude: lonlat.lon,
      latitude: lonlat.lat,
      zoom: zoomLevel
    };
    return $.JSONCookie('position', mapPosition, {
      expires: 30
    });
  };

  loadMapPosition = function() {
    var position;
    position = $.JSONCookie('position');
    if (!position.longitude) {
      position = {
        longitude: 2777381.0927341,
        latitude: 8439319.5947809,
        zoom: 11
      };
    }
    return position;
  };

  mapPosition = loadMapPosition();

  getTileURL = function(bounds) {
    var path, res, url, x, y, ymax, z;
    z = this.map.getZoom() - this.map.getZoomForResolution(78271.516953125) + 1;
    res = this.map.getResolution();
    x = Math.round((bounds.left - this.maxExtent.left) / (res * this.tileSize.w));
    ymax = 1 << z;
    y = Math.round((this.maxExtent.top - bounds.top) / (res * this.tileSize.h));
    y = ymax - y - 1;
    path = z + "/" + x + "/" + y + "." + this.type;
    url = this.url;
    if (url instanceof Array) url = this.selectUrl(path, url);
    return url + path;
  };

  getMLLXYZ = function(bounds) {
    var limit, res, x, y, z;
    res = this.getServerResolution();
    x = Math.round((bounds.left - this.maxExtent.left) / (res * this.tileSize.w));
    y = Math.round((this.maxExtent.top - bounds.top) / (res * this.tileSize.h));
    z = this.map.getZoom() - this.map.getZoomForResolution(78271.516953125) + 1;
    if (this.wrapDateLine) {
      limit = Math.pow(2, z);
      x = ((x % limit) + limit) % limit;
    }
    return {
      'x': x,
      'y': y,
      'z': z
    };
  };

  mapQuest = new OpenLayers.Layer.OSM("MapQuest", ["http://otile1.mqcdn.com/tiles/1.0.0/osm/${z}/${x}/${y}.png", "http://otile2.mqcdn.com/tiles/1.0.0/osm/${z}/${x}/${y}.png", "http://otile3.mqcdn.com/tiles/1.0.0/osm/${z}/${x}/${y}.png", "http://otile4.mqcdn.com/tiles/1.0.0/osm/${z}/${x}/${y}.png"], {
    transitionEffect: 'resize',
    attribution: "Data, imagery and map information provided by <a href='http://www.mapquest.com/'  target='_blank'>MapQuest</a>, <a href='http://www.openstreetmap.org/' target='_blank'>Open Street Map</a> and contributors, <a href='http://creativecommons.org/licenses/by-sa/2.0/' target='_blank'>CC-BY-SA</a>  <img src='http://developer.mapquest.com/content/osm/mq_logo.png' border='0'>"
  });

  bingAerial = new OpenLayers.Layer.Bing({
    name: "Bing - Aerial",
    key: bingKey,
    type: "Aerial",
    transitionEffect: 'resize'
  });

  bingHybrid = new OpenLayers.Layer.Bing({
    name: "Bing - Hybrid",
    key: bingKey,
    type: "AerialWithLabels",
    transitionEffect: 'resize'
  });

  bingRoad = new OpenLayers.Layer.Bing({
    name: "Bing - Road",
    key: bingKey,
    type: "Road",
    transitionEffect: 'resize'
  });

  mmlMaastoKartat = new OpenLayers.Layer.XYZ("Maanmittauslaitos - Maastokartat", "http://tiles.kartat.kapsi.fi/peruskartta/${z}/${x}/${y}.png", {
    sphericalMercator: true,
    attribution: "<br/>Maastokartat ja ilmakuvat &copy; <a class='attribution' href='http://maanmittauslaitos.fi/'>MML</a>, jakelu <a class='attribution' href='http://kartat.kapsi.fi/'>Kapsi ry</a>",
    transitionEffect: 'resize'
  });

  osmCycle = new OpenLayers.Layer.OSM("OpenStreetMap - Cycle", ["http://a.tile.opencyclemap.org/cycle/${z}/${x}/${y}.png", "http://b.tile.opencyclemap.org/cycle/${z}/${x}/${y}.png", "http://c.tile.opencyclemap.org/cycle/${z}/${x}/${y}.png"], {
    transitionEffect: 'resize'
  });

  osmStandard = new OpenLayers.Layer.OSM("OpenStreetMap - Standard", null, {
    transitionEffect: 'resize'
  });

  osmTransport = new OpenLayers.Layer.OSM("OpenStreetMap - Transport", ["http://a.tile2.opencyclemap.org/transport/${z}/${x}/${y}.png", "http://b.tile2.opencyclemap.org/transport/${z}/${x}/${y}.png", "http://c.tile2.opencyclemap.org/transport/${z}/${x}/${y}.png"], {
    transitionEffect: 'resize'
  });

  oviSatellite = new OpenLayers.Layer.XYZ("Ovi Maps - Satellite", ["http://e.maptile.maps.svc.ovi.com/maptiler/maptile/newest/hybrid.day/${z}/${x}/${y}/256/png8", "http://f.maptile.maps.svc.ovi.com/maptiler/maptile/newest/hybrid.day/${z}/${x}/${y}/256/png8"], {
    transitionEffect: 'resize',
    sphericalMercator: true,
    numZoomLevels: 21
  });

  oviStreets = new OpenLayers.Layer.XYZ("Ovi Maps - Street", ["http://a.maptile.maps.svc.ovi.com/maptiler/maptile/newest/normal.day/${z}/${x}/${y}/256/png8", "http://b.maptile.maps.svc.ovi.com/maptiler/maptile/newest/normal.day/${z}/${x}/${y}/256/png8"], {
    transitionEffect: 'resize',
    sphericalMercator: true,
    numZoomLevels: 21
  });

  oviTransit = new OpenLayers.Layer.XYZ("Ovi Maps - Transit", ["http://c.maptile.maps.svc.ovi.com/maptiler/maptile/newest/normal.day.transit/${z}/${x}/${y}/256/png8", "http://d.maptile.maps.svc.ovi.com/maptiler/maptile/newest/normal.day.transit/${z}/${x}/${y}/256/png8"], {
    transitionEffect: 'resize',
    sphericalMercator: true,
    numZoomLevels: 21
  });

  mmlIlmakuvat = new OpenLayers.Layer.XYZ("Maanmittauslaitos - Ilmakuvat", "http://tiles.kartat.kapsi.fi/ortokuva/${z}/${x}/${y}.png", {
    getXYZ: getMLLXYZ,
    minScale: 100000,
    isBaseLayer: false,
    visibility: false,
    attribution: "<br/>Maastokartat ja ilmakuvat &copy; <a class='attribution' href='http://maanmittauslaitos.fi/'>MML</a>, jakelu <a class='attribution' href='http://kartat.kapsi.fi/'>Kapsi ry</a>"
  });

  trafiMerikartta = new OpenLayers.Layer.XYZ("Liikennevirasto - Merikartta", "http://mapserver.sailmate.fi/fi/images/", {
    'type': 'png',
    'getURL': getTileURL,
    isBaseLayer: false,
    transparent: true,
    numZoomLevels: 16,
    visibility: false,
    attribution: "<br/>Merikartat &copy; <a class='attribution' href='http://liikennevirasto.fi/'>Liikennevirasto</a>, jakelu <a class='attribution' href='http://www.sailmate.fi/'><img src='./images/sailmate.png' style='margin-bottom: -4px'/></a>"
  });

  geoLocateVector = new OpenLayers.Layer.Vector('geoLocate');

  geoLocateControl = new OpenLayers.Control.Geolocate({
    id: 'locate-control',
    type: OpenLayers.Control.TYPE_TOGGLE,
    geolocationOptions: {
      enableHighAccuracy: false,
      maximumAge: 0,
      timeout: 7000
    },
    eventListeners: {
      activate: function() {
        return map.addLayer(geoLocateVector);
      },
      deactivate: function() {
        map.removeLayer(geoLocateVector);
        return geoLocateVector.removeAllFeatures();
      },
      locationupdated: function(e) {
        geoLocateVector.removeAllFeatures();
        return geoLocateVector.addFeatures([
          new OpenLayers.Feature.Vector(e.point, null, {
            graphicName: 'cross',
            strokeColor: '#f00',
            strokeWidth: 2,
            fillOpacity: 0,
            pointRadius: 10
          })
        ]);
      }
    }
  });

  map = new OpenLayers.Map({
    div: "map",
    theme: null,
    projection: defaultProjection,
    controls: [
      new OpenLayers.Control.Attribution(), new OpenLayers.Control.TouchNavigation({
        dragPanOptions: {
          enableKinetic: true
        }
      }), geoLocateControl
    ],
    layers: [mapQuest, osmCycle, mmlMaastoKartat, bingHybrid],
    eventListeners: {
      "moveend": storeMapPosition
    }
  });

  map.setCenter(new OpenLayers.LonLat(mapPosition.longitude, mapPosition.latitude), mapPosition.zoom);

  map.setBaseLayer(mapQuest);

}).call(this);
