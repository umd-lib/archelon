### Basic Example:

```js
<LabeledThing subjectURI='example' predicateURI='creator' />
```

### Pre-populated example

Default values can be pre-populated using the "value", "label", and "sameAs" properties:

```js
<LabeledThing subjectURI='example' predicateURI='title'
 value={{
   'value': {'@id': 'http://example.com/id/foobar'},
   'label': {'@value': 'Foobar', '@language': 'en'},
   'sameAs': {'@id': 'http://example.com/baz'}
 }}
/>
```
