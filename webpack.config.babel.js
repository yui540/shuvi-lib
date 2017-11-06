import webpack from 'webpack';
import path from 'path';

const SRC = 'src';
const DEST = 'lib';

const js = {
  entry: path.join(__dirname, `${ SRC }/shuvi-lib.js`),
  output: {
    path: `${ __dirname }/${ DEST }`,
    filename: 'shuvi-lib.min.js'
  },
  module: {
    rules: [
      {
        test: /\.js/,
        loader: 'babel-loader',
        exclude: /node_modules/
      }
    ]
  }
};

module.exports = [js]
