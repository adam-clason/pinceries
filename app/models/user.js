var mongoose = require('mongoose');
var Schema = mongoose.Schema;

module.exports = mongoose.model('User', new Schema({
	id : String, 
	firstName : String,
	lastName : String,
}));
