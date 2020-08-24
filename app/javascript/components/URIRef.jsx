import React from "react"
import PropTypes, { string } from "prop-types"

const N3 = require('n3');
const { DataFactory } = N3;
const { namedNode, defaultGraph } = DataFactory;

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

    // save the initial value
    this.initialStatement = this.getStatement(props.value['@id']);
    this.initialURI = props.value['@id'] || '';
    this.state = {
      uri: props.value['@id'] || "",
      uriChanged: false,
    };

    this.handleTextChange = this.handleTextChange.bind(this);
    this.getStatement = this.getStatement.bind(this);
  }

  handleTextChange(event) {
    let newURI = event.target.value;
    let uriChanged = (newURI !== this.initialURI);
    this.setState(function (state, props){
      if (props.onChange) {
        props.onChange(uriChanged);
      }
      return {
        uri: newURI,
        uriChanged: uriChanged,
      };
    });
  }

  getStatement(uri) {
    const writer = new N3.Writer({format: 'N-Triples'});
    return writer.quadToString(
        namedNode(this.props.subjectURI),
        namedNode(this.props.predicateURI),
        namedNode(uri),
        defaultGraph(),
    );
  }

  componentWillUnmount() {
    if (this.props.notifyContainer && !this.props.value.isNew) {
      this.props.notifyContainer(this.initialStatement)
    }
  }

  render () {
    let statement = this.getStatement(this.state.uri);
    let valueIsUnchanged = (this.initialStatement === statement);

    return (
      <React.Fragment>
        <input type="hidden" name="delete[]" value={this.initialStatement} disabled={this.props.value.isNew || valueIsUnchanged}/>
        <input type="hidden" name="insert[]" value={statement} disabled={valueIsUnchanged}/>
        <input name={this.props.name} title={this.state.datatype} value={this.state.uri} onChange={this.handleTextChange} size="40"/>
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
  notifyContainer: undefined,
}

export default URIRef;
