var path              = require('path');
var webpack           = require('webpack');

var plugins = [
  new webpack.NoErrorsPlugin(),
  new webpack.optimize.OccurenceOrderPlugin(),
  new webpack.DefinePlugin({
    'process.env': {
      'NODE_ENV': JSON.stringify('production')
    }
  }),
  new webpack.optimize.UglifyJsPlugin({
    compressor: {
      screw_ie8: true,
      warnings: false
    }
  })
]

module.exports = {
  devtool: 'cheap-source-map',
  node: {
    fs: "empty",
    child_process: "empty",
    module: "empty",
    jison: "empty",
    repl: "empty",
  },
  resolve: {
    extensions: ['', '.js', '.coffee']
  },
  entry: [ './index.coffee' ],
  output: {
    filename: 'bundle.js',
    path: path.join(__dirname, 'dist'),
    libraryTarget: 'umd',
    library: 'MeshbluJsonSchemaResolver'
  },
  plugins: plugins,
  module: {
    loaders: [
      {
        test: /\.coffee$/, loader: 'coffee'
      }
    ]
  }
};
