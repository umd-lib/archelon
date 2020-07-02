### Repeatable PlainLiteral example

```js
import PlainLiteral from './PlainLiteral';
<Repeatable name="test"
   componentType="PlainLiteral"
   defaultValue={{value: "Lorem ipsum", language: ""}}
/>
```

### Repeatable PlainLiteral with preset values

```js
import PlainLiteral from './PlainLiteral';

let values= [
  {value: 'First Line', language: 'en'},
  {value: '二行目', language: 'ja'},
  {value: 'Third Line', language: 'en'},
];

<Repeatable name="test"
   componentType="PlainLiteral"
   defaultValue={{value: "", language: ""}}
   values={values}
/>
```

### Repeatable TypedLiteral only allowing up to 3 entries

```js
import TypedLiteral from './TypedLiteral';

let values = [
  {value: '2020-06-23', datatype: "http://id.loc.gov/datatypes/edtf"},
  {value: '2019-07-04', datatype: "http://www.w3.org/2001/XMLSchema#date"}
];

<Repeatable name="test"
   componentType="TypedLiteral"
   maxValues={3}
   values={values}
   defaultValue={{value: "", datatype: "http://id.loc.gov/datatypes/edtf"}}
/>
```

### Repeatable ControlledURIRef

```js
import ControlledURIRef from './ControlledURIRef';

let vocab={'http://example.com/vocab#foo': 'Foo', 'http://example.com/vocab#bar': 'Bar'};

let values = [{value: 'http://example.com/vocab#foo'}, {value: 'http://example.com/vocab#bar'}];

<Repeatable name="test"
   componentType="ControlledURIRef"
   vocab={vocab}
   values={values}
   defaultValue={{ value: 'http://example.com/vocab#foo' }}
/>
```
