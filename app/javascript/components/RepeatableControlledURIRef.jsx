import React from "react"
import PlainLiteral from "./PlainLiteral"
import PropTypes from "prop-types"
import Repeatable from "./Repeatable"
import ControlledURIRef from "./ControlledURIRef";

/**
 * This class is mainly intended to serve as "syntactic sugar" so that the
 * "react-rails" gem can use the "Repeatable" component with the ControlledURIRef
 * component, without having to pass anonymous JavaScript functions as
 * properties.
 *
 *  Sample Rails view usage:
 *
 * ```
 * <%= react_component(
 *       "RepeatableControlledURIRef", {
 *       maxValues: 5,
 *       paramPrefix: "repeatable_controlled_value",
 *       name: 'title',
 *       values: [
 *         "http://vocab.lib.umd.edu/form#maps",
 *         "http://vocab.lib.umd.edu/form#newspapers"]
 *       }
 *     )
 * %>
 * ```
 *
 */
class RepeatableControlledURIRef extends React.Component {
  render() {
    return (
      <Repeatable
         maxValues={this.props.maxValues}
         values={this.props.values}
         newElement={(value) => <ControlledURIRef paramPrefix={this.props.paramPrefix} name={this.props.name} value={value.value} vocab={this.props.vocab} />}
         defaultValue={this.props.defaultValue}
      />
    );
  }
}

RepeatableControlledURIRef.propTypes = {
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

export default RepeatableControlledURIRef;
