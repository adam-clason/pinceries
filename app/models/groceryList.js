var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var Ingredient = new Schema({ 
	name : String,
	amount : String,
	category: String,
	count: Number,
	pinId: String,
	checked: Boolean 
});

var GroceryList = mongoose.model('GroceryList', new Schema({
	userId : Schema.Types.ObjectId,
	name : String, 
	ingredients : [Ingredient]
}));

module.exports = GroceryList;

