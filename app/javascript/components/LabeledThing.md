### Basic Example:

```js
<LabeledThing paramPrefix='example' name='creator' />
```

### Pre-populated example

Default values can be pre-populated using the "value" and "obj" properties: 

```js
<LabeledThing paramPrefix='example' name='title'
 value={{'@id': 'http://example.com/id/foobar'}}
 obj={{
    'http://www.w3.org/2000/01/rdf-schema#label': { '@value': 'Foobar', '@language': 'en'},
    'http://www.w3.org/2002/07/owl#sameAs': { '@id': 'http://example.com/baz' }
}}/>
```
