// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery.ui.slider
//= require bootstrap
//= require bootstrap-button
//= require proj4js/lib/proj4js.js
//= require proj4js/lib/projCode/aea.js
//= require proj4js/lib/projCode/laea.js
//= require proj4js/lib/projCode/merc.js
//= require proj4js/lib/projCode/ortho.js
//= require gina-map-layers/gina-openlayers.js
//= require gina-map-layers/projections/all.js
//= require raphael-min.js
//= require spin.min.js
//= require filters
//= require styles
//= require legends
//= require map
//= require ubermap
//= require_self

$.fn.spin = function(opts) {
  this.each(function() {
    var $this = $(this),
        data = $this.data();

    if (data.spinner) {
      data.spinner.stop();
      delete data.spinner;
    }
    if (opts !== false) {
      data.spinner = new Spinner($.extend({color: $this.css('color')}, opts)).spin(this);
    }
  });
  return this;
};
