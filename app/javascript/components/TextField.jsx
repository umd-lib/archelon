import React from "react"
import PropTypes from "prop-types"
import LiteralValue from "./LiteralValue";

function lessThanMax(values, max) {
  return max === undefined || values.length < max;
}

/**
 * A component that enables LiteralValue components to be dynamically
 * added and removed.
 *
 * Sample Rails view usage:
 *
 * ```
 * <%= react_component  (:TextField, { param_prefix: 'example', name: 'title', maxValues: 3, values: [
 *   { value: 'First Title', language: 'en' },
 *   { value: 'Second Title', language: 'ja' }
 * ]}) %>
 * ```
 *
 * When used in a form, this will send two arrays `example[title][]` and
 * `example[title_language][]` as HTML paramaters.
 */
class TextField extends React.Component {
  // The maximum number of values the component will allow
  maxValues;

  constructor(props) {
    super(props);

    // Initialize keyCounter
    this.keyCounter = 0;

    let values;
    if(props.values) {
      values = props.values
    } else {
      values = [ {value: "", language: "" }]
    }

    // Populate initial "value" properties with a "key" field
    values.forEach((value) => {
      value["key"] = this.keyCounter;
      this.keyCounter++;
    });

    this.state = {
      values: values,
      canAddValues: lessThanMax(values, props.maxValues)
    }
  };

  // Removes an entry
  handleRemove(index) {
    const values = this.state.values.splice(index, 1);
    this.setState({
      canAddValues: lessThanMax(values, this.props.maxValues)
    })
  }

  // Adds an entry
  handleAdd() {
    const values = this.state.values.slice();
    this.keyCounter = this.keyCounter + 1;
    values.push({value: '', language: '', key: this.keyCounter});
    this.setState({
      values: values,
      canAddValues: lessThanMax(values, this.props.maxValues)
    })
  };

  render () {
    let lastIndex = this.state.values.length - 1;
    return (
      <div>
        {
          this.state.values.map((literal, index) => (
              <div key={literal.key} >
                <LiteralValue param_prefix={this.props.param_prefix} name={this.props.name} value={literal.value} language={literal.language}/>
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

TextField.propTypes = {
  /**
   * The name of the element, used to with `param_prefix` to construct the
   * parameter sent via the form submission.
   */
  name: PropTypes.string,
  /**
   * Combined with the name (`<param_prefix>[<name>][]`) to construct the
   * parameter sent via the form submission.
   */
  param_prefix: PropTypes.string,
  /**
   * Default values to display. This should be a array of maps, i.e.:
   *
   * ```
   * [ {value: <Text to display>, langauge: <ISO-639 language code> } ]
   * ```
   */
  values: PropTypes.array,
  /**
   * The maximum number of entries to allow.
   */
  maxValues: PropTypes.number
}
export default TextField
