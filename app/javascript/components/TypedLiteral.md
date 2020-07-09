Basic Example:

```js
<TypedLiteral subjectURI="example" predicateURI="title"/>
```

Default values can be pre-populated using the "value" property:

```js
<TypedLiteral subjectURI="example" predicateURI="title"
value={{'@value': "2020-06-23", '@type': "http://id.loc.gov/datatypes/edtf"}} />
```
