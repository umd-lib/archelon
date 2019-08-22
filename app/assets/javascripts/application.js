// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require turbolinks

// Required by Blacklight
//= require blacklight/blacklight

// Blacklight loads some Bootstrap plugins, so we can't just add
// bootstrap.min.js to get other Bootstrap functionality (Bootstrap
// don't like it when the plugins are loaded twice). The following
// Bootstrap plugins are needed by the "clipboard" functionality.
//= require bootstrap/tooltip

// For "clipboard-rails" gem
//= require clipboard

//= require_tree .

/* See https://github.com/sadiqmmm/clipboard-rails */
$(document).on('turbolinks:load', function(){
  // Tooltip
  $('.clipboard-btn').tooltip({
    trigger: 'click',
    placement: 'bottom'
  });

  function setTooltip(btn, message) {
    $(btn).tooltip('hide')
      .attr('data-original-title', message)
      .tooltip('show');
  }

  function hideTooltip(btn) {
    setTimeout(function() {
      $(btn).tooltip('hide');
    }, 1000);
  }

  // Clipboard
  var clipboard = new Clipboard('.clipboard-btn');

  clipboard.on('success', function(e) {
    setTooltip(e.trigger, 'Copied!');
    hideTooltip(e.trigger);
  });

  clipboard.on('error', function(e) {
    setTooltip(e.trigger, 'Failed!');
    hideTooltip(e.trigger);
  });
});
