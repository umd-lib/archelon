This "style guide" provides an interactive demonstration of the React
components provided with Archelon.

## Useful Resources

* https://react-styleguidist.js.org/

## "react-rails" Limitations

In React, it is strongly suggested that "composition" be preferred over
"inheritance" when creating React components.

In fact, the documentation (https://reactjs.org/docs/composition-vs-inheritance.html)
contains the following:

> At Facebook, we use React in thousands of components, and we haven’t found
> any use cases where we would recommend creating component inheritance hierarchies.

One mechanism for replacing inheritance with composition is to pass anonymous
JavaScript functions via "props", that the component then uses. One example
where this is used is the "Repeatable" component -- passing an anonymous
function via the "newElement" property enables the component to construct
new instances without having to be subclassed.

Unfortunately, the "react_component" view helper in the react-rails" gem cannot
pass anonymous JavaScript functions via "props", as it has no mechanism for
describing the function.

For the "Repeatable" component, the workaround is to create a second component
that can provide the "newElement" function to the Repeatable component. See
"RepeatableLiteralValue" and "RepeatableTypedLiteral" in the
"RepeatableComponent.jsx" file.

This solution is less than ideal, because it requires creating a "Repeatable"
version of we might want to make repeatable, but appears to be the only way
to enable the component to work with react-rails.
