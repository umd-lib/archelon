import React from "react"
import PropTypes from "prop-types"

/**
 * Input component consisting of a textbox with an associated datatype.
 *
 *  Sample Rails view usage:
 *
 * ```
 * <%= react_component(:TypedLiteralValue, { paramPrefix: 'example', name: 'title', value: "2020-06-26", datatype: "http://id.loc.gov/datatypes/edtf"}) %>
 * ```
 *
 * When used in a form, this will submit the array `example[title][]`
 * with a single value, `{value: "2020-06-26", datatype: "http://id.loc.gov/datatypes/edtf"}`.
 */
class TypedLiteral extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      value: props.value,
      datatype: props.datatype
    };
    this.handleTextChange = this.handleTextChange.bind(this);
    this.handleLanguageChange = this.handleLanguageChange.bind(this);
  }

  handleTextChange(event) {
    this.setState({value: event.target.value})
  }

  handleLanguageChange(event) {
    this.setState({language: event.target.value})
  }

  render () {
    let textbox_name = `${this.props.paramPrefix}[${this.props.name}][][value]`
    let datatype_name = `${this.props.paramPrefix}[${this.props.name}][][datatype]`

    return (
      <React.Fragment>
        <input title={this.state.datatype} name={textbox_name} value={this.state.value} onChange={this.handleTextChange} size="40"/>
        <input type="hidden" name={datatype_name} value={this.state.datatype}/>
      </React.Fragment>
    );
  }
}

TypedLiteral.propTypes = {
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
   * The default text for the textbox
   */
  value: PropTypes.string,
  /**
   * The RDF datatype URI, i.e. http://id.loc.gov/datatypes/edtf
   */
  datatype: PropTypes.string
}

export default TypedLiteral;
