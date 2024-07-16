// Entry point for the build script in your package.json
import * as bootstrap from "bootstrap"
import Blacklight from "blacklight-frontend";
import githubAutoCompleteElement from "@github/auto-complete-element";

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
