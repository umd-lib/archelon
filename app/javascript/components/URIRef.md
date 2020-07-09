Basic Example:

```js
<URIRef subjectURI="example" predicateURI="title" />
```

Default values can be pre-populated using the "value" property:

```js
let value = { "@id": "http://example.com/vocab#bar" };
<URIRef subjectURI="example" predicateURI="title" value={value} />
```
