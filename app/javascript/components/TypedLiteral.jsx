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
 *     subjectURI: 'example',
 *     predicateURI: 'title',
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
    let textbox_name = `${this.props.subjectURI}[${this.props.predicateURI}][][@value]`
    let datatype_name = `${this.props.subjectURI}[${this.props.predicateURI}][][@type]`

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
   * The predicateURI of the element, used to with `subjectURI` to construct the
   * parameter sent via the form submission.
   */
  predicateURI: PropTypes.string,
  /**
   * Combined with the predicateURI (`<subjectURI>[<predicateURI>][]`) to
   * construct the parameter sent via the form submission.
   */
  subjectURI: PropTypes.string,
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
