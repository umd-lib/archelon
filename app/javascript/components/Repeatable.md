### Repeatable LabeledThing example

```js
<Repeatable name="test" componentType="LabeledThing" subjectURI='example' predicateURI='creator' />
```

### Repeatable LabeledThing with preset values

```js
<Repeatable name="test" predicateURI="repeatableLabeledThingPredicate" componentType="LabeledThing" subjectURI='subjectURI'
            values={[
               { value: {'@id': 'http://example.com/id/foobar'},
                 label: {'@value': 'Foobar', '@language': 'en'},
                 sameAs: {'@id': 'http://example.com/baz'},
               },
               { value: {'@id': 'http://example.com/id/quuz'},
                 label: {'@value': 'Quuz', '@language': 'ja'},
                 sameAs: {'@id': 'http://example.com/quuzbar'},
               }
            ]
            }
            defaultValue={{
                value: {'@id': 'subjectURI#newUUID'},
                label: {'@value': '', '@language': 'en'},
                sameAs: {'@id': 'http://example.com/baz'},
            }}
            />
```

### Repeatable PlainLiteral example

```js
<Repeatable name="test"
   componentType="PlainLiteral"
   defaultValue={{"@value": "Lorem ipsum", "@language": ""}}
/>
```

### Repeatable PlainLiteral with preset values

```js
import Repeatable from "./Repeatable";

let values= [
  {'@value': 'First Line', '@language': 'en'},
  {'@value': '二行目', '@language': 'ja'},
  {'@value': 'Third Line', '@language': 'en'},
];

<Repeatable name="test"
   componentType="PlainLiteral"
   defaultValue={{"@value": "", "@language": ""}}
   values={values}
/>
```

### Repeatable TypedLiteral only allowing up to 3 entries

```js
import Repeatable from "./Repeatable";

let values = [
  {'@value': '2020-06-23', '@type': "http://id.loc.gov/datatypes/edtf"},
  {'@value': '2019-07-04', '@type': "http://www.w3.org/2001/XMLSchema#date"}
];

<Repeatable name="test"
   componentType="TypedLiteral"
   maxValues={3}
   values={values}
   subjectURI="example"
   defaultValue={{'@value': '', '@type': "http://id.loc.gov/datatypes/edtf"}}
/>
```

### Repeatable ControlledURIRef

```js
import Repeatable from "./Repeatable";

let vocab={'http://example.com/vocab#foo': 'Foo', 'http://example.com/vocab#bar': 'Bar'};

let values = [{'@id': 'http://example.com/vocab#foo'}, {'@id': 'http://example.com/vocab#bar'}];

<Repeatable name="test"
   componentType="ControlledURIRef"
   vocab={vocab}
   values={values}
   defaultValue={{ '@id': 'http://example.com/vocab#foo' }}
/>
```

### Repeatable URIRef

```js
import URIRef from './URIRef';

let values = [{value: { '@id': 'http://example.com/vocab#foo'} }];

<Repeatable name="test"
   componentType="URIRef"
   values={values}
   defaultValue={{ value: { '@id': '' }}}
/>
```
