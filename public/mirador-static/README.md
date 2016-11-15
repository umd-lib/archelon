# mirador-static

Current Mirador version: `v2.1.0` IIIF/mirador: [v2.1.0](https://github.com/ProjectMirador/mirador/releases/tag/v2.1.0)
with modification at [v2.1.0-10-f8f72b0](https://github.com/xtai-umd/mirador/commit/f8f72b0) in xtai-umd/mirador.

## Running this version

To prevent cross-origin requests, please clone this repo to a local web server and run via HTTP.

A simple local web server: [https://www.browsersync.io/](https://www.browsersync.io/).

If using browsersync, run `browser-sync start --server` and visit: [http://localhost:3000/mirador.html](http://localhost:3000/mirador.html).

## Testing annotations

Four annotation files are included:

- [`annotations/annotation-p1-static.json`](https://github.com/xtai-umd/mirador-static/blob/gh-pages/annotations/annotation-p1-static.json)
- [`annotations/annotation-p1-dynamic.json`](https://github.com/xtai-umd/mirador-static/blob/gh-pages/annotations/annotation-p1-dynamic.json).
- [`annotations/annotation-p2-static.json`](https://github.com/xtai-umd/mirador-static/blob/gh-pages/annotations/annotation-p2-static.json)
- [`annotations/annotation-p2-dynamic.json`](https://github.com/xtai-umd/mirador-static/blob/gh-pages/annotations/annotation-p2-dynamic.json).

These files are referenced in the local manifest file [`manifest.json`](manifest.json) for page 1 and 2.

`annotationTypeStyles` now supports customizable annotation styles, hovering styles, and ability to show or hide annotation tooltips.  

Annotation with @type: `umd:searchResult`, `umd:articleSegment`, and `umd:Article` will have different appearance according to the seetings of `'annotationTypeStyles'` in [`site.js`](site.js):
```js
'annotationTypeStyles': {
  'umd:searchResult': {
    'strokeColor': 'rgba(255, 255, 255, 0)',
    'fillColor': 'yellow',
    'fillColorAlpha': 0.1,
    'hoverColor': 'rgba(255, 255, 255, 0)',
    'hoverFillColor': 'yellow',
    'hoverFillColorAlpha': 0.5,
    'notShowTooltip': true
  },
  'umd:articleSegment': {
    'strokeColor': 'rgba(0, 0, 0, 0.2)',
    'fillColor': 'green',
    'fillColorAlpha': 0.1,
    'hoverColor': 'rgba(255, 255, 255, 0.2)',
    'hoverFillColor': 'yellow',
    'hoverFillColorAlpha': 0.5,
    'notShowTooltip': true
  },
  'umd:Article': {
    'strokeColor': 'rgba(255, 255, 255, 0)',
    'fillColor': 'green',
    'fillColorAlpha': 0,
    'hoverColor': 'rgba(255, 255, 255, 0.2)',
    'hoverFillColor': 'green',
    'hoverFillColorAlpha': 0.2
  }
}
```

An example oa:annotation:
```json
{
  "@id" : "http://iiif-sandbox.lib.umd.edu/annotation/article/001",
  "@type" : ["oa:Annotation", "umd:articleSegment"],
  "resource" : [ {
    "@type" : "dctypes:Text",
    "chars": ""
  } ],
  "on" : {
    "@type" : "oa:SpecificResource",
    "selector" : {
      "@type" : "oa:FragmentSelector",
      "value" : "xywh=335,1240,820,500"
    },
    "full" : "http://iiif-sandbox.lib.umd.edu/manifests/sn83045081/1902-01-15/1"
  },
  "motivation" : "oa:highlighting"
}
```
