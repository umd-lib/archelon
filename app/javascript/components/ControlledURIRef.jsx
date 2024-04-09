import React from "react"
import PropTypes from "prop-types"

const N3 = require('n3');
const { DataFactory } = N3;
const { namedNode, defaultGraph } = DataFactory;

/**
 * Input component with a dropdown whose values come from a controlled vocabulary.
 *
 *  Sample Rails view usage:
 *
 * ```
 * <%=
 *   react_component(
 *     :ControlledURIRef, {
 *       subjectURI: 'example',
 *       predicateURI: 'object_type',
 *       vocab: VocabularyService.get_vocabulary('object_type').as_hash,
 *       value: {
 *         '@id' => 'http://example.com/foo#bar'
 *       }
 *     }
 *   )
 * %>
 * ```
 *
 * When used in a form, this will submit the array `example[object_type][]`
 * with a single value `{"@id": "http://example.com/foo#bar"}`
 */
class ControlledURIRef extends React.Component {
  constructor(props) {
    super(props);
    let uri = props.value['@id'] || '';
    // save the initial value
    this.initialStatement = this.getStatement(uri);
    this.state = {
      uri: uri
    }
    this.noStartingValue = (this.state.uri === '');

    // Determine if the "uri" value is in the vocabulary
    let isUriInVocabulary = false;
    for (const [uri, label] of Object.entries(this.props.vocab)) {
      if (uri === this.state.uri) {
        isUriInVocabulary = true;
        break;
      }
    }

    // If uri is not in vocabulary, append it to the vocabulary so that it
    // shows up in the dropdown. Do not add if the uri is the empty value,
    // as a separate "empty" option is added by default.
    if (!isUriInVocabulary && this.state.uri !== "") {
      props.vocab[this.state.uri] = this.state.uri;
    }

    this.handleChange = this.handleChange.bind(this);
    this.getStatement = this.getStatement.bind(this);
  };

  handleChange(event) {
    this.setState({ uri: event.target.value })
  };

  getStatement(uri) {
    const writer = new N3.Writer({format: 'N-Triples'});
    return writer.quadToString(
        namedNode(this.props.subjectURI),
        namedNode(this.props.predicateURI),
        namedNode(uri),
        defaultGraph(),
    );
  };

  render () {
    let statement = this.getStatement(this.state.uri);
    let valueIsUnchanged = (this.initialStatement === statement);

    // valueIsUnset is for the case where there was an initial non-empty value
    // and the user has chosen the empty value. This should disable the
    // "insert" hidden field, so that a SPARQL INSERT statement is not generated
    let valueIsUnset = (this.state.uri === "");

    let entries = Object.entries(this.props.vocab).map(([uri, label]) => ([uri, label]));
    const sortStringValues = (a, b) => (a[1] > b[1] && 1) || (a[1] === b[1] ? 0 : -1)
    entries.sort(sortStringValues); // Note: sort is "in-place"

    return (
      <React.Fragment>
        <input type="hidden" name="delete[]" value={this.initialStatement} disabled={this.props.value.isNew || this.noStartingValue || valueIsUnchanged}/>
        <input type="hidden" name="insert[]" value={statement} disabled={valueIsUnchanged || valueIsUnset}/>
        <select name={this.props.name} value={this.state.uri} onChange={this.handleChange}>
          <option key="" value=""/>
          {entries.map(([uri, label]) => (
              <option key={uri} value={uri}>{label}</option>
          ))}
        </select>
      </React.Fragment>
    );
  }
}

ControlledURIRef.propTypes = {
  /**
   * The predicateURI of the element, used with `subjectURI` to construct the
   * parameter sent via the form submission.
   */
  predicateURI: PropTypes.string,
  /**
   * Combined with the predicateURI (`<subjectURI>[<predicateURI>][]`) to
   * construct the parameter sent via the form submission.
   */
  subjectURI: PropTypes.string,
  /**
   * The default selected value for the dropdown
   */
  value: PropTypes.object,
  /**
   * The vocabulary to display
   */
  vocab: PropTypes.object,
}

ControlledURIRef.defaultProps = {
  vocab: {},
  value: { '@id': '' },
}

export default ControlledURIRef
