import ImportGlobPlugin from "esbuild-plugin-import-glob";
import esbuild from "esbuild"

import path from "path";

const entryPoints = [ 'application.js' ]

esbuild.context({
  bundle: true,
  entryPoints: entryPoints,
  outdir: path.join(process.cwd(), "app/assets/builds"),
  absWorkingDir: path.join(process.cwd(), "app/javascript"),
  plugins: [ImportGlobPlugin.default()],
  sourcemap: process.env.RAILS_ENV != "production",
  minify: process.env.RAILS_ENV == "production",
  publicPath: "/assets",
  format: "esm",
  logLevel: "info",
  // Needed because of "LabeledThing", which gets renamed to "_LabeledThing",
  // see https://github.com/evanw/esbuild/issues/510
  keepNames: true
}).then(context => {
  if (process.argv.includes("--watch")) {
    // Enable watch mode
    // From https://github.com/rails/jsbundling-rails/issues/8#issuecomment-1403699565
    context.watch()
  } else {
    // Build once and exit if not in watch mode
    context.rebuild().then(result => {
      context.dispose()
    })
  }
}).catch(() => process.exit(1))
