Basic Example:

```js
<TextField name="test" />
```

The number of values can be limited using the "maxValues" property.
The following allows a maximum of 3 LiteralValue components:

```js
<TextField name="test" maxValues="3"/>
```

Default values can be pre-populated using the "values" property:

```js
let values= [
  {value: 'First Line', language: 'en'},
  {value: '二行目', language: 'ja'},
  {value: 'Third Line', language: 'en'},
];
<TextField name="test" values={values} />
```
