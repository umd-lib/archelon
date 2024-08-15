// Entry point for the build script in your package.json
import * as bootstrap from "bootstrap"
import Blacklight from "blacklight-frontend";
import githubAutoCompleteElement from "@github/auto-complete-element";

// JQuery
// From https://stackoverflow.com/a/70925500
import './add_jquery'

// rails-ujs
import './add_rails_ujs'

import './resource'

// Load in React components
import components from "./components/**/*.jsx"

let componentsContext = {}
components.forEach((component) => {
  componentsContext[component.default.name] = component.default
})

const ReactRailsUJS = require("react_ujs")

ReactRailsUJS.getConstructor = (name) => {
  return componentsContext[name]
}

import "./channels"
