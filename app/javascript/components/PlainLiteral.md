### Basic Example:

```js
<PlainLiteral paramPrefix='example' name='title' />
```

### Pre-populated example

Default values can be pre-populated using the "value" property: 

```js
<PlainLiteral paramPrefix='example' name='title'
 value={{'@value': 'Lorem ipsum', '@language': 'en'}}/>
```