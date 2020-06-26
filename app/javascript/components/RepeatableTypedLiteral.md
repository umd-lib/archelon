### Basic Example

```js
<RepeatableTypedLiteral paramPrefix='example' name='title' />
```

### RepeatableTypedLiteral with preset values

```js
let values = [
  {value: '2020-06-23', datatype: "http://id.loc.gov/datatypes/edtf"},
  {value: '2019-07-04', datatype: "http://www.w3.org/2001/XMLSchema#date"}
];

<RepeatableTypedLiteral paramPrefix='example' name='title'
   defaultValue={{value: "", datatype: ""}}
   values={values}
/>
```

### RepeatableTypedLiteral only allowing up to 3 entries

```js
<RepeatableTypedLiteral paramPrefix='example' name='title'
   maxValues={3}
/>
```
