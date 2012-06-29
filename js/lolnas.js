(function() {
  var htmlLunch, onPopupClose, onPopupFeatureSelect, onPopupFeatureUnselect, restaurantPopupHtml, transformLonLat;

  transformLonLat = function(lon, lat) {
    var lonLat;
    lonLat = new OpenLayers.LonLat(lon, lat);
    lonLat = lonLat.transform(new OpenLayers.Projection("EPSG:4326"), new OpenLayers.Projection("EPSG:900913"));
    return lonLat;
  };

  window.loadRestaurants = function(data) {
    var lolnasLayer, lonLat, marker, restaurant, selectControl, styleMap, _i, _len, _ref;
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
    _ref = data.restaurants;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      restaurant = _ref[_i];
      lonLat = transformLonLat(restaurant.longitude, restaurant.latitude);
      marker = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.Point(lonLat.lon, lonLat.lat));
      marker.popupHtml = restaurantPopupHtml(restaurant);
      lolnasLayer.addFeatures([marker]);
    }
    selectControl = new OpenLayers.Control.SelectFeature(lolnasLayer, {
      onSelect: onPopupFeatureSelect,
      onUnselect: onPopupFeatureUnselect
    });
    window.map.addControl(selectControl);
    selectControl.activate();
    window.map.addLayer(lolnasLayer);
    return window.lolnasLayer = lolnasLayer;
  };

  onPopupClose = function(evt) {
    return selectControl.unselect(selectedFeature);
  };

  onPopupFeatureSelect = function(feature) {
    return alert("" + feature.popupHtml);
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

}).call(this);
