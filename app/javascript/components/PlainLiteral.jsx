import React from "react"
import PropTypes from "prop-types"

const N3 = require('n3');
const { DataFactory } = N3;
const { namedNode, literal, defaultGraph } = DataFactory;

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
    '': '',
    'en': 'English',
    'ja': 'Japanese',
    'ja-latn': 'Japanese (Romanized)',
  };

  constructor(props) {
    super(props);
    // save the initial value
    this.initialStatement = this.getStatement(props.value['@value'], props.value['@language']);
    this.state = {
      value: props.value['@value'],
      language: props.value['@language']
    };

    this.initialValue = props.value['@value'];
    this.initialLanguage = props.value['@language'];

    this.handleTextChange = this.handleTextChange.bind(this);
    this.handleLanguageChange = this.handleLanguageChange.bind(this);
    this.getStatement = this.getStatement.bind(this);
  };

  handleTextChange(event) {
    let newValue = event.target.value;
    let valueChanged = (newValue !== this.initialValue);
    this.setState(function(state, props) {
      if (props.onChange) {
        props.onChange(valueChanged || state.languageChanged);
      }
      return {
        value: newValue,
        valueChanged: valueChanged,
      };
    });
  };

  handleLanguageChange(event) {
    let newLanguage = event.target.value;
    let languageChanged = (newLanguage !== this.initialLanguage)
    this.setState(function(state, props) {
      if (props.onChange) {
        props.onChange(languageChanged || state.valueChanged);
      }
      return {
        language: newLanguage,
        languageChanged: languageChanged,
      };
    });
  }

  getStatement(value, language) {
    const writer = new N3.Writer({format: 'N-Triples'});
    return writer.quadToString(
        namedNode(this.props.subjectURI),
        namedNode(this.props.predicateURI),
        literal(value, language || undefined),
        defaultGraph(),
    );
  }

  componentWillUnmount() {
    if (this.props.notifyContainer && !this.props.value.isNew) {
      this.props.notifyContainer(this.initialStatement)
    }
  }

  render () {
    let statement = this.getStatement(this.state.value, this.state.language);
    let valueIsUnchanged = !(this.state.valueChanged || this.state.languageChanged)

    return (
      <React.Fragment>
        <input type="hidden" name="delete[]" value={this.initialStatement} disabled={this.props.value.isNew || valueIsUnchanged}/>
        <input type="hidden" name="insert[]" value={statement} disabled={valueIsUnchanged}/>
        <input value={this.state.value} onChange={this.handleTextChange} size="40"/>
        &nbsp;Language:&nbsp;
        <select value={this.state.language} onChange={this.handleLanguageChange}>
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
  value: { '@value': '', '@language': '' },
  notifyContainer: undefined,
}

export default PlainLiteral;
