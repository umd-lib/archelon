import React from "react"
import PropTypes from "prop-types"

/**
 * Input component consisting of a textbox, and language dropdown list.
 *
 *  Sample Rails view usage:
 *
 * ```
 * <%= react_component(
 *   :PlainLiteral,
 *   {
 *     subjectURI: 'example',
 *     predicateURI: 'title',
 *     value: {
 *       '@id' => "Lorem ipsum",
 *       '@language' => "en"
 *     }
 *   }
 * ) %>
 * ```
 *
 * When used in a form, this will submit the array `example[title][]`
 * with a single value, `{"@value": "Lorem ipsum", "@language": "en"}`.
 */
class PlainLiteral extends React.Component {
  // The options for the dropdown, using ISO-639 language codes
  LANGUAGES = {
    '': 'None',
    'en': 'English',
    'ja': 'Japanese',
    'ja-latn': 'Japanese (Romanized)',
  };

  constructor(props) {
    super(props);
    this.state = {
      value: props.value['@value'],
      language: props.value['@language']
    };
    this.handleTextChange = this.handleTextChange.bind(this);
    this.handleLanguageChange = this.handleLanguageChange.bind(this);
  };

  handleTextChange(event) {
    this.setState({value: event.target.value})
  };

  handleLanguageChange(event) {
    this.setState({language: event.target.value})
  }

  render () {
    let textbox_name = `${this.props.subjectURI}[${this.props.predicateURI}][][@value]`
    let language_name = `${this.props.subjectURI}[${this.props.predicateURI}][][@language]`

    return (
      <React.Fragment>
        <input name={textbox_name} value={this.state.value} onChange={this.handleTextChange} size="40"/>
        &nbsp;Language:&nbsp;
        <select name={language_name} value={this.state.language} onChange={this.handleLanguageChange}>
          {Object.entries(this.LANGUAGES).map(([code, name]) => (
              <option key={code} value={code}>{name}</option>
          ))}
        </select>
      </React.Fragment>
    );
  }
}

PlainLiteral.propTypes = {
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
   * The text and ISO-639 language code for the textbox, structured as
   * `{"@value": "...", "@language": "..." }`
   */
  value: PropTypes.object,
}

PlainLiteral.defaultProps = {
  value: { '@value': '', '@language': '' }
}

export default PlainLiteral;
