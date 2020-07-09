import React from "react"
import PropTypes, { string } from "prop-types"

/**
 * Input component consisting of a simple textbox.
 *
 *  Sample Rails view usage:
 *
 * ```
 * <%= react_component(:URIRef, { subjectURI: 'example', predicateURI: 'title', value: { "@id": "http://example.com/vocab#bar"} }) %>
 * ```
 *
 * When used in a form, this will submit the array `example[title][]`
 * with a single value, `{"@id": "http://example.com/vocab#bar"}`.
 */
class URIRef extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      uri: props.value['@id'] || "",
    };

    this.handleTextChange = this.handleTextChange.bind(this);
  }

  handleTextChange(event) {
    this.setState({ uri: event.target.value })
  }

  render () {
    let textbox_name = `${this.props.subjectURI}[${this.props.predicateURI}][][@id]`

    return (
      <React.Fragment>
        <input title={this.state.datatype} name={textbox_name} value={this.state.uri} onChange={this.handleTextChange} size="40"/>
      </React.Fragment>
    );
  }
}

URIRef.propTypes = {
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
   * The default text for the textbox
   */
  value: PropTypes.shape({
    "@id": string
  })
}

URIRef.defaultProps = {
  value: { '@id': '' },
}

export default URIRef;
