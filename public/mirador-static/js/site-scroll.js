/* site */

// Mirador global instance
var m = '';
var sidePanelVisible = false;

// Required variables for OCR text side-by-side feature
var umdMiradorOCR = true;
var umdMiradorOCRText = '';
var umdMiradorOCRHovered = 0;

$(function() {
  // create temporary manifest uri
  // var manifestPcdmID = getParamValue('manifest');
  // var iiifURLPrefix = decodeURIComponent(getParamValue('iiifURLPrefix')); // default 'https://iiiflocal/manifests/'
  // var manifestURI = iiifURLPrefix + manifestPcdmID;
  var manifestURI = './manifest.json';

  // to get the manifest before initiate the Mirador viewer
  $.ajax({
    url: manifestURI,
    dataType: 'json',
    async: true,
    success: function (data) {
      // get page CanvasID or first page
      // var canvasID = getCanvasID(iiifURLPrefix, manifestPcdmID, data);
      var canvasID = 'http://iiif-sandbox.lib.umd.edu/manifests/sn83045081/1902-01-15/2';
      m = Mirador({
        'id': 'mirador-viewer',
        'layout': '1x1',
        'buildPath': 'build/mirador/',
        'data': [
          { 'manifestUri': manifestURI, 'location': 'University of Maryland', 'manifestContent': data }
          // { "manifestUri": "http://iiif.harvardartmuseums.org/manifests/object/299843", "location": "Harvard University"}
        ],
        'mainMenuSettings': {
          'show': false
        },
        'windowObjects': [{
          // loadedManifest: "http://iiif.harvardartmuseums.org/manifests/object/299843",
          // viewType: "ImageView",
          'loadedManifest': data['@id'],
          'canvasID': canvasID,
          'viewType': 'ScrollView',
          'displayLayout': false,
          'sidePanel' : true,
          'sidePanelVisible': false,
          'sidePanelOptions' : {
            'toc' : false,
            'annotations' : true
          },
          'canvasControls': {
            'annotations': {
              'annotationLayer': true,
              'annotationCreation': false, 
              'annotationState': 'on'
            }
          }
        }],
        'drawingToolsSettings': {
          'selectedColor': 'yellow',
          'strokeColor': 'rgba(255, 255, 255, 0)',
          'fillColor': 'yellow',
          'fillColorAlpha': 0.1,
          'hoverColor': 'rgba(255, 255, 255, 0)',
          'hoverFillColor': 'yellow',
          'hoverFillColorAlpha': 0.5,
          //customize anno styling
          'annotationTypeStyles': {
            'umd:searchResult': {
              'strokeColor': 'rgba(255, 255, 0, 0.6)',
              'fillColor': 'yellow',
              'fillColorAlpha': 0.4,
              'hoverColor': 'rgba(255, 255, 0, 0.6)',
              'hoverFillColor': 'yellow',
              'hoverFillColorAlpha': 0.6,
              'hideTooltip': true
            },
            'umd:articleSegment': {
              'strokeColor': 'rgba(255, 255, 255, 0.2)',
              'fillColor': 'green',
              'fillColorAlpha': 0.1,
              'hoverColor': 'rgba(255, 255, 255, 0.2)',
              'hoverFillColor': 'green',
              'hoverFillColorAlpha': 0.4,
              'hideTooltip': true
            },
            'umd:Article': {
              'strokeColor': 'rgba(255, 255, 255, 0)',
              'fillColor': 'green',
              'fillColorAlpha': 0.1,
              'hoverColor': 'rgba(255, 255, 255, 0.2)',
              'hoverFillColor': 'green',
              'hoverFillColorAlpha': 0.4,
              'hideTooltip': true
            },
            'umd:Line': {
              'strokeColor': 'rgba(255, 255, 0, 0.05)',
              'fillColor': 'yellow',
              'fillColorAlpha': 0.01,
              'hoverColor': 'rgba(255, 255, 0, 0.4)',
              'hoverFillColor': 'yellow',
              'hoverFillColorAlpha': 0.4,
              'hideTooltip': true
            }
          }
        },
      });
    },
    complete: function () {
      m.eventEmitter.subscribe('windowUpdated', function(event, options) {
        // when sidePanelVisible changed
        if (typeof options.sidePanelVisible !== 'undefined') {
          m.eventEmitter.publish('sidePanelToggled');
          sidePanelVisible = options.sidePanelVisible;
          $('div.sidePanel').css('overflow', 'scroll').css('width', '');
        }
        // when annotation is ready
        if (typeof options.annotationState !== 'undefined') {
          var a = document.querySelectorAll('[id^="draw_canvas_"]')[0];
          if (typeof a !== 'undefined' && a.id !== 'undefined') {
            if (options.annotationState === 'pointer') {
              // add event listener to osd annotation canvas
              document.getElementById(a.id).removeEventListener('click', ocr);
              document.getElementById(a.id).addEventListener('click', ocr);
            } else {
              // remove event listener if no annotation on screen
              document.getElementById(a.id).removeEventListener('click', ocr);
            }
          }
        }
        // when switch viewType
        if (typeof options.viewType !== 'undefined') {
          if (options.viewType === 'ImageView') {
            $('div.sidePanel').html('<h2 style=\"color: #a40404;\">Selection Text</h2><p><a style=\"color: #006699;\" href=\"http://www.lib.umd.edu/\" target=\"_blank\">Feedback</a></p><p style=\"color: #555555;\">Click on annotations to display selection text.</p>');
          } else {
            $('div.sidePanel').html('<h2 style=\"color: #a40404;\">Selection Text</h2><p><a style=\"color: #006699;\" href=\"http://www.lib.umd.edu/\" target=\"_blank\">Feedback</a></p><p style=\"color: #555555;\">Switch to the Image View and click on annotations to display selection text.</p>');
            if (sidePanelVisible) {
              m.eventEmitter.publish('sidePanelVisibilityByTab', false);
            }
          }
          // enable selection on side panel and meta data information panel
          $('div.sidePanel').mousemove(function(e){
            e.stopPropagation();
          });
          $('div.content-container > div.overlay').mousemove(function(e){
            e.stopPropagation();
          });
        }
      });
    }
  });
});

// event listener for OCR text side-by-side feature
function ocr() {
  if (umdMiradorOCRHovered > 0 && umdMiradorOCRText) {
    if (!sidePanelVisible) {
      m.eventEmitter.publish('sidePanelVisibilityByTab', true);
    }
    $('div.sidePanel').html('<h2 style=\"color: #a40404;\">Selection Text</h2><p><a style=\"color: #006699;\" href=\"http://www.lib.umd.edu/\" target=\"_blank\">Feedback</a></p><p style=\"color: #555555;\">' + umdMiradorOCRText.replace(/(?:-\r\n|-\r|-\n)/g, '').replace(/(?:\r\n|\r|\n)/g, ' ') + '</p>');
  }
}
