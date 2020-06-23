import React from "react"
import PropTypes from "prop-types"

/**
 * Input component consisting of a textbox with an associated datatype.
 *
 *  * Sample Rails view usage:
 *
 * ```
 * <%= react_component(:TypedLiteralValue, { param_prefix: 'example', name: 'title', value: "Lorem ipsum", datatype: "http://id.loc.gov/datatypes/edtf"}) %>
 * ```
 * When used in a form, this will send two arrays `example[title][]` and
 * `example[title_datatype][]` as HTML paramaters.
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
    let textbox_name = `${this.props.param_prefix}[${this.props.name}][]`
    let datatype_name = `${this.props.param_prefix}[${this.props.name}_datatype][]`

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
   * The default text for the textbox
   */
  value: PropTypes.string,
  /**
   * The RDF datatype URI, i.e. http://id.loc.gov/datatypes/edtf
   */
  datatype: PropTypes.string
}

export default TypedLiteral;
