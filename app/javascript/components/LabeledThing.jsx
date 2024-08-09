import React from "react"
import PropTypes from "prop-types"
import URIRef from "./URIRef";
import PlainLiteral from "./PlainLiteral";
import { v4 as uuid } from "uuid"

const N3 = require('n3');
const { DataFactory } = N3;
const { namedNode, defaultGraph } = DataFactory;

const labelPredicate = 'http://www.w3.org/2000/01/rdf-schema#label';
const sameAsPredicate = 'http://www.w3.org/2002/07/owl#sameAs';

class LabeledThing extends React.Component {
  constructor(props) {
    super(props);
    let value = props.value

    this.subject = "";
    if (value && value['value'] && value['value']['@id']) {
      this.subject = value['value']['@id'];
    }
    if (this.subject === '') {
      this.subject = props.subjectURI + '#' + uuid();
    }
    // save the initial value
    this.initialStatement = this.getStatement(this.subject);

    let label = value.label || LabeledThing.defaultProps.value.label;
    let sameAs = value.sameAs || LabeledThing.defaultProps.value.sameAs;

    // propagate the newness flag
    label.isNew = value.isNew;
    sameAs.isNew = value.isNew;

    this.state = {
      label: label,
      labelChanged: false,
      sameAs: sameAs,
      sameAsChanged: false,
    };

    this.getStatement = this.getStatement.bind(this);
    this.handleLabelChange = this.handleLabelChange.bind(this);
    this.handleSameAsChange = this.handleSameAsChange.bind(this);
  }

  handleLabelChange(isChanged) {
    this.setState({ labelChanged: isChanged });
  }

  handleSameAsChange(isChanged) {
    this.setState({ sameAsChanged: isChanged })
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
    return (
        <React.Fragment>
          <input type="hidden" name="insert[]" value={this.initialStatement} disabled={!(this.state.labelChanged || this.state.sameAsChanged)}/>
          <PlainLiteral name={this.props.name} subjectURI={this.subject} predicateURI={labelPredicate} value={this.state.label}
          onChange={this.handleLabelChange} notifyContainer={this.props.notifyContainer}/>
          &nbsp;URI:&nbsp;
          <URIRef subjectURI={this.subject} predicateURI={sameAsPredicate} value={this.state.sameAs}
          onChange={this.handleSameAsChange} notifyContainer={this.props.notifyContainer}/>
        </React.Fragment>
    );
  }
}

LabeledThing.propTypes = {
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
   * The subject URI of the embedded object, as `{"@id": "..."}`
   */
  value: PropTypes.object,
  /**
   * The graph for the embedded object
   */
  label: PropTypes.object,
  sameAs: PropTypes.object,
}

LabeledThing.defaultProps = {
  value: {
    value: { '@id': '' },
    label: { '@value': '', '@language': '' },
    sameAs: { '@id': '' },
  },
  notifyContainer: undefined
}

export default LabeledThing
