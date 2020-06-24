### Basic Example

```js
<RepeatablePlainLiteral param_prefix='example' name='title' />
```

### RepeatablePlainLiteral with preset values

```js
let values= [
  {value: 'First Line', language: 'en'},
  {value: '二行目', language: 'ja'},
  {value: 'Third Line', language: 'en'},
];

<RepeatablePlainLiteral param_prefix='example' name='title'
   defaultValue={{value: "", language: ""}}
   values={values}
/>
```

### RepeatablePlainLiteral only allowing up to 3 entries

```js
<RepeatablePlainLiteral param_prefix='example' name='title'
   maxValues={3}
/>
```
