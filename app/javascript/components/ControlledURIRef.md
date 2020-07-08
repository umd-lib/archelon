### Basic Example:

```js
<ControlledURIRef subjectURI='example' name='title'
 vocab={{'http://example.com/vocab#foo': 'Foo', 'http://example.com/vocab#bar': 'Bar'}}/>
```

### Pre-populated example

Default values can be pre-populated using the "value" property:

```js
<ControlledURIRef subjectURI='example' name='title' value={{'@id': 'http://example.com/vocab#bar'}}
 vocab={{'http://example.com/vocab#foo': 'Foo', 'http://example.com/vocab#bar': 'Bar'}}/>
```
