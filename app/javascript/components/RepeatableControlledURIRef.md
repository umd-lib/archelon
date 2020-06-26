### Basic Example

```js
<RepeatableControlledURIRef paramPrefix='example' name='title'
 vocab={{'http://example.com/vocab#foo': 'Foo', 'http://example.com/vocab#bar': 'Bar'}}/>
```

### RepeatableControlledURIRef with preset values

```js
let values= [
  {value: 'http://example.com/vocab#bar'},
  {value: 'http://example.com/vocab#foo'}
];

<RepeatableControlledURIRef paramPrefix='example' name='title'
   defaultValue={{value: ""}}
   values={values}
   vocab={{'http://example.com/vocab#foo': 'Foo', 'http://example.com/vocab#bar': 'Bar'}}/>
```

### RepeatableControlledURIRef only allowing up to 3 entries

```js
<RepeatableControlledURIRef paramPrefix='example' name='title'
   maxValues={3}
   vocab={{'http://example.com/vocab#foo': 'Foo', 'http://example.com/vocab#bar': 'Bar'}}/>
```
