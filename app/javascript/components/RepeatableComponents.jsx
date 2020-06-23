import React from "react"
import Repeatable from "./Repeatable"
import PlainLiteral from "./PlainLiteral"
import TypedLiteral from "./TypedLiteral"

// Note: These classes are only provided due to the inability of the
// "react-rails" gem to pass anonymous JavaScript functions as properties.
//
// See:
//   * https://github.com/reactjs/react-rails/issues/164
//   * https://github.com/reactjs/react-rails/issues/179
//
// The following classes should be considered "syntactic sugar", and not
// an example of React best practices.

/**
 * Repeatable PlainLiteral component
 */
class RepeatablePlainLiteral extends React.Component {
  render() {
    return (
      <Repeatable
         maxValues={this.props.maxValue}
         values={this.props.values}
         newElement={(value) => <PlainLiteral param_prefix={this.props.param_prefix} name={this.props.name} value={value.value} language={value.language} />}
         defaultValue={{value: this.props.defaultValue}}
      />
    );
  }
}

/**
 * Repeatable TypedLiteral component
 */
class RepeatableTypedLiteral extends React.Component {
  render() {
    return (
      <Repeatable
         maxValues={this.props.maxValue}
         values={this.props.values}
         newElement={(value) => <TypedLiteral param_prefix={this.props.param_prefix} name={this.props.name} value={value.value} datatype={value.datatype} />}
         defaultValue={{value: this.props.defaultValue}}
      />
    );
  }
}

export {RepeatablePlainLiteral, RepeatableTypedLiteral};
