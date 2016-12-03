var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var User = mongoose.model('User', new Schema({
	id : String, 
	activeGroceryListId : Schema.Types.ObjectId,
	firstName : String,
	lastName : String
}));

module.exports = User;


