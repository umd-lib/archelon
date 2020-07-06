Basic Example:

```js
<TypedLiteral paramPrefix="example" name="title"/>
```

Default values can be pre-populated using the "value" property:

```js
<TypedLiteral paramPrefix="example" name="title"
value={{'@value': "2020-06-23", '@type': "http://id.loc.gov/datatypes/edtf"}} />
```
