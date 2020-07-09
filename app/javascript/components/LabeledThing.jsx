import React from "react"
import PropTypes from "prop-types"
import URIRef from "./URIRef";
import PlainLiteral from "./PlainLiteral";
import { v4 as uuid } from "uuid"

const labelPredicate = 'http://www.w3.org/2000/01/rdf-schema#label';
const sameAsPredicate = 'http://www.w3.org/2002/07/owl#sameAs';

const defaultGraph = {}
defaultGraph[labelPredicate] = [{ '@value': '', '@language': '' }]
defaultGraph[sameAsPredicate] = [{ '@id': '' }]

class LabeledThing extends React.Component {
  constructor(props) {
    super(props);
    let value = props.value

    this.subject = value['value']['@id'];
    if (this.subject === '') {
      this.subject = props.paramPrefix + '#' + uuid();
    }

    // Modify subject with "key" value when used via "Repeatable"
    this.index = props.value["key"];
    if (this.index !== undefined && this.index !== null) {
      this.subject = `${this.subject}${this.index}`;
    }

    this.label = value["label"];
    this.sameAs = value["sameAs"];

    this.state = {
      label: value["label"],
      sameAs: value["sameAs"],
    };
  }

  render () {
    let fieldName = `${this.props.paramPrefix}[${this.props.name}][][@id]`
    return (
        <React.Fragment>
          <input type="hidden" name={fieldName} value={this.subject}/>
          <PlainLiteral paramPrefix={this.subject} name={labelPredicate} value={this.state.label}/>
          &nbsp;URI:&nbsp;
          <URIRef paramPrefix={this.subject} name={sameAsPredicate} value={this.state.sameAs}/>
        </React.Fragment>
    );
  }
}

LabeledThing.propTypes = {
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
  }
}

export default LabeledThing
