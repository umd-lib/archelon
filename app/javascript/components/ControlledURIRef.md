### Basic Example:

```js
<ControlledURIRef paramPrefix='example' name='title'
 vocab={{'http://example.com/vocab#foo': 'Foo', 'http://example.com/vocab#bar': 'Bar'}}/>
```

### Pre-populated example

Default values can be pre-populated using the "value":

```js
<ControlledURIRef paramPrefix='example' name='title' value='http://example.com/vocab#bar'
 vocab={{'http://example.com/vocab#foo': 'Foo', 'http://example.com/vocab#bar': 'Bar'}}/>
```
