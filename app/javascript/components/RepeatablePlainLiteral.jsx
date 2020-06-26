import React from "react"
import PlainLiteral from "./PlainLiteral"
import PropTypes from "prop-types"
import Repeatable from "./Repeatable"

/**
 * This class is mainly intended to serve as "syntactic sugar" so that the
 * "react-rails" gem can use the "Repeatable" component with the PlainLiteral
 * component, without having to pass anonymous JavaScript functions as
 * properties.
 *
 *  Sample Rails view usage:
 *
 * ```
 * <%= react_component(
 *       "RepeatablePlainLiteral", {
 *       maxValues: 5,
 *       paramPrefix: "repeatable_plain_literal",
 *       name: 'title',
 *       values: [
 *         {value: 'First Line', language: 'en'},
 *         {value: '二行目', language: 'ja'},
 *         {value: 'Third Line', language: 'en'}]
 *       }
 *     )
 * %>
 * ```
 *
 */
class RepeatablePlainLiteral extends React.Component {
  render() {
    return (
      <Repeatable
         maxValues={this.props.maxValues}
         values={this.props.values}
         newElement={(value) => <PlainLiteral paramPrefix={this.props.paramPrefix} name={this.props.name} value={value.value} language={value.language} />}
         defaultValue={this.props.defaultValue}
      />
    );
  }
}

RepeatablePlainLiteral.propTypes = {
  /**
   * The name of the element, used to with `paramPrefix` to construct the
   * parameter sent via the form submission.
   */
  name: PropTypes.string,
  /**
   * Combined with the name (`<paramPrefix>[<name>][]`) to construct the
   * parameter sent via the form submission.
   */
  paramPrefix: PropTypes.string,
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
