(function() {
  var bindPoiMarkerClick, disableEventsInsideBubble, htmlLunch, iconSize, lolnasLayer, positionLonLat, restaurantPopupHtml;

  lolnasLayer = new OpenLayers.Layer.Markers("Lounaat (Helsinki)", {
    visibility: false,
    attribution: "<br/>Lounastiedot toimittaa <a href='http://www.lolnas.fi'><img src='./images/lolnas.png' style='margin-bottom: -8px'/></a>"
  });

  window.map.addLayer(lolnasLayer);

  iconSize = new OpenLayers.Size(21, 25);

  positionLonLat = function(lon, lat) {
    var lonLat;
    lonLat = new OpenLayers.LonLat(lon, lat);
    lonLat = lonLat.transform(new OpenLayers.Projection("EPSG:4326"), new OpenLayers.Projection("EPSG:900913"));
    return lonLat;
  };

  window.loadRestaurants = function(data) {
    var icon, marker, position, restaurant, _i, _len, _ref, _results;
    _ref = data.restaurants;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      restaurant = _ref[_i];
      position = positionLonLat(restaurant.longitude, restaurant.latitude);
      icon = new OpenLayers.Icon("./images/restaurant.png", iconSize, new OpenLayers.Pixel(-(iconSize.w / 2), -iconSize.h));
      marker = new OpenLayers.Marker(position, icon);
      marker.icon.imageDiv.style.cursor = 'pointer';
      lolnasLayer.addMarker(marker);
      _results.push(bindPoiMarkerClick(marker, position, restaurantPopupHtml(restaurant)));
    }
    return _results;
  };

  disableEventsInsideBubble = function(popup) {
    return popup.events.un({
      "click": popup.onclick,
      scope: popup
    });
  };

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

  bindPoiMarkerClick = function(marker, position, content) {
    var markerClick;
    markerClick = function(evt) {
      if (window.openPopup) window.openPopup.hide();
      if (this.popup) {
        this.popup.toggle();
      } else {
        this.popup = new OpenLayers.Popup(null, position, new OpenLayers.Size(200, 200), content, true);
        disableEventsInsideBubble(this.popup);
        window.map.addPopup(this.popup);
        this.popup.updateSize();
        this.popup.show();
      }
      return window.openPopup = this.popup;
    };
    return marker.events.register("click", marker, markerClick);
  };

}).call(this);
