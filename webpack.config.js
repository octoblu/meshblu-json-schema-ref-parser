var path = require("path")
var webpack = require("webpack")

var plugins = [
  new webpack.NoEmitOnErrorsPlugin(),
  new webpack.optimize.OccurrenceOrderPlugin(),
  new webpack.DefinePlugin({
    "process.env": {
      NODE_ENV: JSON.stringify("production"),
    },
  }),
]

module.exports = {
  devtool: "cheap-source-map",
  node: {
    fs: "empty",
    child_process: "empty",
    module: "empty",
    jison: "empty",
    repl: "empty",
  },
  resolve: {
    extensions: [".js", ".coffee"],
  },
  entry: ["./index.coffee"],
  output: {
    filename: "bundle.js",
    path: path.join(__dirname, "dist"),
    libraryTarget: "umd",
    library: "MeshbluJsonSchemaResolver",
  },
  plugins: plugins,
  module: {
    rules: [
      {
        test: /\.coffee$/,
        loader: "coffee-loader",
      },
    ],
  },
}
