import PropTypes from "prop-types"
import React from "react"
import Repeatable from "./Repeatable";
import TypedLiteral from "./TypedLiteral";

/**
 * RepeatableTypedLiteral component
 *
 * This class is mainly intended to serve as "syntactic sugar" so that the
 * "react-rails" gem can use the "Repeatable" component with the TypedLiteral
 * component, without having to pass anonymous JavaScript functions as
 * properties.
 */
class RepeatableTypedLiteral extends React.Component {
  render() {
    return (
      <Repeatable
         maxValues={this.props.maxValues}
         values={this.props.values}
         newElement={(value) => <TypedLiteral param_prefix={this.props.param_prefix} name={this.props.name} value={value.value} datatype={value.datatype} />}
         defaultValue={this.props.defaultValue}
      />
    );
  }
}

RepeatableTypedLiteral.propTypes = {
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
   * The default text and datatype properties for the TypedLiteral entries
   */
  values: PropTypes.array,
  /**
   * The maximum number of elements to allow.
   */
  maxValues: PropTypes.number,
  /**
   * The default value to use for additional elements
   */
  defaultValue: PropTypes.object
}

export default RepeatableTypedLiteral;
