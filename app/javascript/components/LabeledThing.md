### Basic Example:

```js
<LabeledThing paramPrefix='example' name='creator' />
```

### Pre-populated example

Default values can be pre-populated using the "value", "label", and "sameAs" properties: 

```js
<LabeledThing paramPrefix='example' name='title'
 value={{'@id': 'http://example.com/id/foobar'}}
 label={{'@value': 'Foobar', '@language': 'en'}}
 sameAs={{'@id': 'http://example.com/baz'}}
/>
```
