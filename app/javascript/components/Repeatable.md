### Basic example, using an "input" textbox

```js
 <Repeatable
    newElement={(value) => <input type="text" defaultValue={value.value}/>}
    defaultValue={{value: "Sample Value"}}
 />
```

### PlainLiteral example

```js
import PlainLiteral from './PlainLiteral';
<Repeatable name="test"
   newElement={(value) => {return <PlainLiteral paramPrefix='example' name='title' value={value.value} language={value.language}/>; }}
   defaultValue={{value: "Lorem ipsum", language: ""}}
/>
```

### PlainLiteral with preset values

```js
import PlainLiteral from './PlainLiteral';

let values= [
  {value: 'First Line', language: 'en'},
  {value: '二行目', language: 'ja'},
  {value: 'Third Line', language: 'en'},
];

<Repeatable name="test"
   newElement={
     (value) => {
       return <PlainLiteral paramPrefix='example' name='title' value={value.value} language={value.language}/>;
     }
   }
   defaultValue={{value: "", language: ""}}
   values={values}
/>
```

### TypedLiteral only allowing up to 3 entries

```js
import TypedLiteral from './TypedLiteral';

let values = [
  {value: '2020-06-23', datatype: "http://id.loc.gov/datatypes/edtf"},
  {value: '2019-07-04', datatype: "http://www.w3.org/2001/XMLSchema#date"}
];

<Repeatable name="test"
   maxValues={3}
   values={values}
   newElement={
     (value) => {
       return (
         <TypedLiteral paramPrefix='example' name='title' value={value.value}
                       datatype={value.datatype} />
        );
     }
   }
   defaultValue={{value: "", datatype: "http://id.loc.gov/datatypes/edtf"}}
/>
```
