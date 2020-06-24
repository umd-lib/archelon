const path = require('path')
module.exports = {
  components: 'app/javascript/components/**/*.jsx',

  webpackConfig: {
    module: {
      rules: [
        // Babel loader will use your project’s babel.config.js
        {
          test: /\.jsx?$/,
          exclude: /node_modules/,
          loader: 'babel-loader'
        },
        // Other loaders that are needed for your components
        {
          test: /\.css$/,
          use: ['style-loader', 'css-loader']
        }
      ]
    }
  },
  sections: [
    {
      name: 'Introduction',
      content: 'app/javascript/components/docs/introduction.md'
    },
    {
      name: 'UI Components',
      components: 'app/javascript/components/**/*.jsx',
      exampleMode: 'expand', // 'hide' | 'collapse' | 'expand'
      usageMode: 'expand' // 'hide' | 'collapse' | 'expand'
    }
  ]
}

