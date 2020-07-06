import React from "react"
import PropTypes from "prop-types"

/**
 * Input component consisting of a textbox with an associated datatype.
 *
 *  Sample Rails view usage:
 *
 * ```
 * <%= react_component(
 *   :TypedLiteralValue,
 *   {
 *     paramPrefix: 'example',
 *     name: 'title',
 *     value: {
 *       '@value': '2020-06-26',
 *       '@type': 'http://id.loc.gov/datatypes/edtf'
 *     }
 *   }
 * ) %>
 * ```
 *
 * When used in a form, this will submit the array `example[title][]`
 * with a single value, `{"@value": "2020-06-26", "@type": "http://id.loc.gov/datatypes/edtf"}`.
 */
class TypedLiteral extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      value: props.value['@value'],
      datatype: props.value['@type']
    };
    this.handleTextChange = this.handleTextChange.bind(this);
  }

  handleTextChange(event) {
    this.setState({ value: event.target.value })
  }

  render () {
    let textbox_name = `${this.props.paramPrefix}[${this.props.name}][][@value]`
    let datatype_name = `${this.props.paramPrefix}[${this.props.name}][][@type]`

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
   * The initial text and datatype for the component. in the form
   * `{"@value": "...", "@type": "http://..."}`
   */
  value: PropTypes.object,
}

TypedLiteral.defaultProps = {
  value: { '@value': '', '@type': '' }
}

export default TypedLiteral;
