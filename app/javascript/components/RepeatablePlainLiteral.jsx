import React from "react"
import PlainLiteral from "./PlainLiteral"
import PropTypes from "prop-types"
import Repeatable from "./Repeatable"

/**
 * RepeatablePlainLiteral component
 *
 * This class is mainly intended to serve as "syntactic sugar" so that the
 * "react-rails" gem can use the "Repeatable" component with the PlainLiteral
 * component, without having to pass anonymous JavaScript functions as
 * properties.
 */
class RepeatablePlainLiteral extends React.Component {
  render() {
    return (
      <Repeatable
         maxValues={this.props.maxValues}
         values={this.props.values}
         newElement={(value) => <PlainLiteral param_prefix={this.props.param_prefix} name={this.props.name} value={value.value} language={value.language} />}
         defaultValue={this.props.defaultValue}
      />
    );
  }
}

RepeatablePlainLiteral.propTypes = {
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
   * The default text and language properties for the PlainLiteral entries
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

export default RepeatablePlainLiteral;
