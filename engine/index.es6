
const Model   = require('./model');
const utils   = require('./utils.es6');
const Matrix  = require('./matrix').Matrix;


// TODO: replace input to model() with object per data contract once it is
//       finalized

module.exports.model = (data, dependent, exponents, multipliers) => {
  dependent = dependent || (data.size()[1] - 1);
  data = new Matrix(data);

  var inputColumns = data.subset(
    ':',
    utils.range(0, dependent).concat(utils.range(dependent + 1, data.shape[1]))
  ) , outputColumn = data.col(dependent);

  return new Model(inputColumns, outputColumn, exponents, multipliers);
};
