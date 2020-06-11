import React from "react"
import PropTypes from "prop-types"
class LiteralValue extends React.Component {
  LANGUAGES = {
    '': 'None',
    'en': 'English',
    'ja': 'Japanese'
  };
  constructor(props) {
    super(props);
    this.state = {
      value: props.value,
      language: props.language
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
    return (
      <React.Fragment>
        <input name={this.props.name} value={this.state.value} onChange={this.handleTextChange} size="40"/>
        <label>
          Language
        </label>
        <select name={this.props.name + '__language'} value={this.state.language} onChange={this.handleLanguageChange}>
          {Object.entries(this.LANGUAGES).map(([code, name]) => (
              <option value={code}>{name}</option>
          ))}
        </select>
      </React.Fragment>
    );
  }
}

export default LiteralValue
