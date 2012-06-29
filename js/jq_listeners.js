(function() {

  $("#locate").live('click', function() {
    var control;
    control = map.getControlsBy("id", "locate-control")[0];
    if (control.active) {
      return control.getCurrentLocation();
    } else {
      return control.activate();
    }
  });

  $("#lolnasLayer").live('click', function() {
    var layer;
    layer = window.lolnasLayer;
    return layer.setVisibility(!layer.getVisibility());
  });

  $("#aerialLayer").live('click', function() {
    var layer;
    layer = window.aerialLayer;
    return layer.setVisibility(!layer.getVisibility());
  });

}).call(this);
