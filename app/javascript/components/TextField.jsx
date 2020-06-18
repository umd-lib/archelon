import React from "react"
import PropTypes from "prop-types"
import LiteralValue from "./LiteralValue";

function lessThanMax(values, max) {
  return max === undefined || values.length < max;
}
class TextField extends React.Component {
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

  handleRemove(index) {
    const values = this.state.values.splice(index, 1);
    this.setState({
      canAddValues: lessThanMax(values, this.props.maxValues)
    })
  }

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
        <label>
          {this.props.name}:
        </label>
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
  name: PropTypes.string,
  values: PropTypes.array
}
export default TextField
