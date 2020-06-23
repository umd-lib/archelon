import React from "react"
import PropTypes from "prop-types"

/**
 * Enables multiple instances of an element to be added/removed.
 *
 * Elements are added by defining a "newElement" and a "defaultValue"
 * property.
 *
 * The "newElement" property is a function that returns a React element.
 * The function should have take a single "value" argument, which is
 * provided by the "defaultValue" property. If a "defaultValue" property
 * is not provided, an empty Object is passed to the "newElement" function.
 *
 * The "maxValues" property sets the maximum instances that can be created.
 *
 * The following example demonstrates using Repeatable to add up to three
 * input textboxes:
 *
 * ```
 * <Repeatable
 *    maxValues={3}
 *    newElement={(value) => <input type="text" defaultValue={value.value}/>}
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
    this.newElement = props.newElement;
    this.defaultValue = props.defaultValue ? props.defaultValue : {};

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

  createNewElement(value) {
    let element = this.newElement(value);
    return element;
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
                {index == lastIndex}
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
   * Function for creating additional elements
   */
  newElement: PropTypes.func.isRequired,
  /**
   * The default value to use for additional elements
   */
  defaultValue: PropTypes.object
}

export default Repeatable;
