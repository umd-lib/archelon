import React from "react"
import PropTypes from "prop-types"

/**
 * Input component with a dropdown whose values come from a controlled vocabulary.
 *
 *  Sample Rails view usage:
 *
 * ```
 * <%=
 *   react_component(
 *     :ControlledURIRef, {
 *       paramPrefix: 'example',
 *       name: 'object_type',
 *       vocab: Vocabulary.find_by(identifier: 'object_type').as_hash,
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
    this.state = {
      uri: props.value['@id'] || ""
    }

    this.handleChange = this.handleChange.bind(this);
  };

  handleChange(event) {
    this.setState({ uri: event.target.value })
  };

  render () {
    let inputName = `${this.props.paramPrefix}[${this.props.name}][][@id]`
    let entries = Object.entries(this.props.vocab).map(([uri, label]) => ([uri, label]));

    const sortStringValues = (a, b) => (a[1] > b[1] && 1) || (a[1] === b[1] ? 0 : -1)
    entries.sort(sortStringValues); // Note: sort is "in-place"

    return (
      <React.Fragment>
        <select name={inputName} value={this.state.uri} onChange={this.handleChange}>
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
