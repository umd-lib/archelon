import React from "react"
import PropTypes from "prop-types"

const N3 = require('n3');
const { DataFactory } = N3;
const { namedNode, defaultGraph } = DataFactory;

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
    // save the initial value
    this.initialStatement = this.getStatement(props.value['@value'], props.value['@type']);
    this.state = {
      value: props.value['@value'],
      datatype: props.value['@type']
    };
    this.handleTextChange = this.handleTextChange.bind(this);
    this.getStatement = this.getStatement.bind(this);
  }

  handleTextChange(event) {
    this.setState({ value: event.target.value })
  }

  getStatement(value, datatype) {
    const writer = new N3.Writer({format: 'N-Triples'});

    // Handle literal value in a special manner, because SPARQL requires
    // "^^" to separate the type, instead of "@" (which is what we would
    // get from DataFactory.literal
    let literalValue = { id: `\"${value}\"` }
    if (datatype) {
      literalValue = { id: `\"${value}\"^^<${datatype}>` }
    }
    let nquads = writer.quadToString(
        namedNode(this.props.subjectURI),
        namedNode(this.props.predicateURI),
        literalValue,
        defaultGraph(),
    );
    return nquads;
  }

  componentWillUnmount() {
    if (this.props.notifyContainer && !this.props.value.isNew) {
      this.props.notifyContainer(this.initialStatement)
    }
  }

  render () {
    let statement = this.getStatement(this.state.value, this.state.datatype);
    let valueIsUnchanged = (this.initialStatement === statement);

    return (
      <React.Fragment>
        <input type="hidden" name="delete[]" value={this.initialStatement} disabled={this.props.value.isNew || valueIsUnchanged}/>
        <input type="hidden" name="insert[]" value={statement} disabled={valueIsUnchanged}/>
        <input title={this.state.datatype} value={this.state.value} onChange={this.handleTextChange} size="40"/>
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
  value: { '@value': '', '@type': '' },
  notifyContainer: undefined,
}

export default TypedLiteral;
