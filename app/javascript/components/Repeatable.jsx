import React from "react"
import PropTypes from "prop-types"
import PlainLiteral from "./PlainLiteral";
import TypedLiteral from "./TypedLiteral";
import ControlledURIRef from "./ControlledURIRef";
import URIRef from "./URIRef";

// Registry of component types that are repeatable.
// Adapted from: https://stackoverflow.com/a/37625215
const registry = {
  PlainLiteral: PlainLiteral,
  TypedLiteral: TypedLiteral,
  ControlledURIRef: ControlledURIRef,
  URIRef: URIRef,
};

/**
 * Enables multiple instances of an element to be added/removed.
 *
 * Elements are added by defining a "componentType" and a "defaultValue"
 * property.
 *
 * The "maxValues" property sets the maximum instances that can be created.
 *
 * The following example demonstrates using Repeatable to add up to three
 * PlainLiteral components:
 *
 * ```
 * <Repeatable
 *    maxValues={3}
 *    componentType="PlainLiteral"
 *    defaultValue={{value: "Sample Value"}}
 * />
 * ```
 */
class Repeatable extends React.Component {
  constructor(props) {
    super(props);

    // Initialize keyCounter
    this.keyCounter = 0;

    this.maxValues = props.maxValues ? parseInt(props.maxValues) : undefined;
    this.componentType = registry[props.componentType];
    this.defaultValue = props.defaultValue || this.componentType.defaultProps.value || {};

    let values;
    if(props.values) {
      values = props.values
    } else {
      values = [ this.defaultValue ]
    }

    // Populate initial "value" properties with a "key" field
    values.forEach((value) => {
      value["key"] = this.keyCounter;
      this.keyCounter++;
    });

    this.state = {
      values: values,
      canAddValues: this.lessThanMax(values)
    }
  };

  lessThanMax(values) {
    return this.maxValues === undefined || values.length < this.maxValues;
  }

  // Removes an entry
  handleRemove(index) {
    const values = this.state.values.splice(index, 1);
    this.setState({
      canAddValues: this.lessThanMax(values)
    })
  }

  // Creates the new element to add
  createNewElement(newValue) {
    const newProps = {
      paramPrefix: this.props.paramPrefix,
      name: this.props.name,
      value: newValue,
      vocab: this.props.vocab,
    }
    return React.createElement(this.componentType, newProps);
  }

  // Adds an entry
  handleAdd() {
    const values = this.state.values.slice();
    let newValue = Object.assign({}, this.defaultValue);
    newValue['key'] = this.keyCounter;
    this.keyCounter = this.keyCounter + 1;
    values.push(newValue);
    this.setState({
      values: values,
      canAddValues: this.lessThanMax(values, this.props.maxValues)
    })
  };


  render () {
    let lastIndex = this.state.values.length - 1;

    return (
      <div>
        {
          this.state.values.map((value, index) => (
              <div key={value.key} >
                { this.createNewElement(value) }
                {
                  // Only display remove button if we have more than one item
                  (lastIndex > 0) &&
                  <button type="button" onClick={() => this.handleRemove(index)}>-</button>
                }
                {
                  // Only show add button on last item
                  index === lastIndex &&
                  <button type="button" onClick={() => this.handleAdd()} hidden={!this.state.canAddValues} disabled={!this.state.canAddValues}>+</button>
                }
              </div>
          ))
        }
      </div>
    );
  }
}

Repeatable.propTypes = {
  /**
   * The maximum number of elements to allow.
   */
  maxValues: PropTypes.number,
  /**
   * The component type to repeat ("PlainLiteral", "TypedLiteral", "ControlledURIRef")
   */
  componentType: PropTypes.string,
  /**
   * The default value to use for additional elements
   */
  defaultValue: PropTypes.object
}

export default Repeatable;
