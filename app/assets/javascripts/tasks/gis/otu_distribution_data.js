/*var _init_otu_distribution_data_widget;
paradigm shift for mouseover fault isolation
_init_otu_distribution_data_widget = */
function init_otu_distribution_data() {
  if ($('#otu_distribution_widget').length) {
    if (document.getElementById('_displayed_distribution_form') != null) {
      var newfcdata = $("#_displayed_distribution_form");
      var fcdata = newfcdata.data('feature-collection');
      var map_canvas = newfcdata.data('map-canvas');


      var otu_map = initializeComplexMap(map_canvas, fcdata);
      add_otu_distribution_data_listeners(otu_map);

      //$('input[type="checkbox"]').change(function () {    // on checkbox change, reset to original feature data
      //  otu_map = initializeComplexMap(map_canvas, newfcdata.data('feature-collection'));
      //  add_otu_distribution_data_listeners(otu_map);
      //});
    }
  }
};

function add_otu_distribution_data_listeners(map) {

  map.data.addListener('click', function (event) {
    map.data.revertStyle();
    map.data.overrideStyle(event.feature, {fillOpacity: 0.5});
  });

  map.data.addListener('mouseover', function (event) {     // interim color shift on mousover paradigm changed to opacity
    map.data.revertStyle();
    map.data.overrideStyle(event.feature, {fillOpacity: 0.7});  // bolder
    //if (event.feature.getProperty('label') != undefined) {
    document.getElementById("displayed_distribution_style").textContent = event.feature.getProperty('label');
    //$("#displayed_distribution_style").html(event.feature.getProperty('label'));
    //}
  });

  map.data.addListener('mouseout', function (event) {
    map.data.revertStyle();
    map.data.overrideStyle(event.feature, {fillOpacity: 0.3});  // dimmer
    //$("#displayed_distribution_style").html('');
  });
}

//$(document).ready(_init_otu_distribution_data_widget);
//$(document).on("page:load", _init_otu_distribution_data_widget);

google.maps.event.addDomListener(window, 'load', init_otu_distribution_data);