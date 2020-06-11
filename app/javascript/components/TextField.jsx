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
    this.handleAdd = this.handleAdd.bind(this);
    this.state = {
      values: props.values || [],
      canAddValues: lessThanMax(props.values, props.maxValues)
    }
  };
  handleAdd() {
    const values = this.state.values.slice();
    values.push({value: '', language: ''});
    this.setState({
      values: values,
      canAddValues: lessThanMax(values, this.props.maxValues)
    })
  };
  render () {
    return (
      <div>
        <label>
          {this.props.name}:
        </label>
        {
          this.state.values.map(literal => (
              <div>
                <LiteralValue value={literal.value} language={literal.language}/>
                <button>-</button>
              </div>
          ))
        }
        <button onClick={this.handleAdd} disabled={!this.state.canAddValues}>+</button>
      </div>
    );
  }
}

TextField.propTypes = {
  name: PropTypes.string,
  values: PropTypes.array
}
export default TextField
