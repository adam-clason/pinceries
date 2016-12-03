var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var Ingredient = new Schema({
	name : String,
	amount : String,
	category: String 
});

var GroceryList = mongoose.model('GroceryList', new Schema({
	ingredients : [Ingredient]
}));

module.exports = GroceryList;


