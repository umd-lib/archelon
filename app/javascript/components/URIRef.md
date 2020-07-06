Basic Example:

```js
<URIRef paramPrefix="example" name="title" />
```

Default values can be pre-populated using the "value" property:

```js
let value = { "@id": "http://example.com/vocab#bar" };
<URIRef paramPrefix="example" name="title" value={value} />
```
