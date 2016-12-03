var express = require('express');
var path = require('path');

var bodyParser = require('body-parser');
var jwt = require('jsonwebtoken');
var mongoose = require('mongoose');
var cors = require('cors');
var User = require('./app/models/user');
var GroceryList = require('./app/models/groceryList');
var https = require('https');

var app = express();

var isProduction = process.env.NODE_ENV === 'production';
var port = isProduction ? process.env.PORT : 3000;

if (!isProduction) {
	var dotenv = require('dotenv');
	dotenv.load();
}

var publicPath = path.resolve(__dirname, 'dist');

app.set('secret', process.env.SECRET);

mongoose.connect(process.env.MONGODB_URI);

app.use(cors());
app.use(express.static(publicPath));
app.use(bodyParser.urlencoded({ extended : false }));
app.use(bodyParser.json());

var apiRoutes = express.Router();

if (!isProduction) {
	apiRoutes.get('/clear', function(req, res) {
		User.remove({}, function () {
			res.json({ success: true, message: "Removed Users!" });
		});

	});	
}


apiRoutes.post('/authenticate', function(req, res) {

	var token = req.body.token;

	if (!token) {
		 res.json({ success: false, message: 'Authentication failed. Must include token in request' });
	} else {

		var options = {
		  host: "api.pinterest.com",
		  port: 443,
		  path: '/v1/me/?access_token=' + token + '&fields=first_name%2Cid%2Clast_name%2Curl',
		  method: 'GET'
		};

		https.request(options, function(pRes) {
			var data = '';

			pRes.setEncoding('utf8');
			pRes.on('data', function (chunk) {
				data += chunk;
			});

			pRes.on('end', function() {
				var pinterestData = JSON.parse(data);
				var pinterestUser = pinterestData['data'];


				User.findOne({
					pinterestId : pinterestUser.id
				}, function(err, user) {
					if (!err) {

						var userInfo = {
							pinterestId : pinterestUser.id,
							firstName : pinterestUser.first_name,
							lastName : pinterestUser.last_name
						};

						var jwtUser = Object.assign({}, userInfo);

						if (!user) {

							var groceryList = new GroceryList({
								ingredients : []
							}); 

							user = new User(userInfo);
							user.activeGroceryListId = groceryList._id;
					

							user.save(function(err, doc) {

								jwtUser.id = doc._id;
								jwtUser.activeGroceryListId = doc.activeGroceryListId;

								groceryList.save(function(err) {

									if (err) {
										res.json({ success : false, message: "There was an error creating the User"});
									} else {
										var token = jwt.sign(jwtUser, app.get('secret'), {
											expiresIn: 60*40*24
										});

										res.json({
											success: true,
											message: "Authorization Successful",
											token: token 
										});
									}

								});
								
							});


						} else {

							jwtUser.id = user._id;
							jwtUser.activeGroceryListId = user.activeGroceryListId;

							var jwtToken = jwt.sign(jwtUser, app.get('secret'), {
								expiresIn: 60*60*24
							});

							res.json({
								success: true,
								message: "Authorization Successful",
								'jwt' : jwtToken
							});
						}
					} else {
						res.json({ success: false, message: "There was an internal error authorizing this user"});
					}
					
				});

			});


		}).on('error', function(err) {
			res.json({ success: false, message: "There as an error authorizing this user"});
		}).end();


	}

});

apiRoutes.use(function(req, res, next) {

  // check header or url parameters or post parameters for token
  var token = req.body.token || req.query.token || req.headers['x-access-token'];

  // decode token
  if (token) {

    // verifies secret and checks exp
    jwt.verify(token, app.get('secret'), function(err, user) {      
      if (err) {
        return res.json({ success: false, message: 'Failed to authenticate token.' });    
      } else {
        // if everything is good, save to request for use in other routes
        req.user = user;    
        next();
      }
    });

  } else {

    // if there is no token
    // return an error
    return res.status(403).send({ 
        success: false, 
        message: 'No token provided.' 
    });
    
  }
});



apiRoutes.post('/groceries/:listId/ingredients', function(req, res) {

	var ingredients = req.body;

	if (req.user) {
		
		GroceryList.findOne({
			userId : req.user.id
		}, function(err, groceryList) {

			if (!groceryList) {
				// Create a new grocery list
				groceryList = new GroceryList({
					userId : req.user.id,
					ingredients : ingredients
				});

				groceryList.save(function(err) {
					if (err) {
						res.json({ success: false, message: "Error adding items to grocery list" });
					} else {
						res.json(groceryList);
					}

				});


			}
			else {
				// Update ingredient list 
				groceryList.ingredients.concat(ingredients);

				groceryList.save(function(err) {
					if (err) {
						res.json({ success: false, message: "Error adding items to grocery list" });
					} else {
						res.json(groceryList);
					}
				});

			}

		});

	} else {
		res.json({ success : false, message: "Couldn't find the user!"});
	}

});

apiRoutes.get('/groceries/:listId/ingredients', function(req, res) {

	GroceryList.findOne({
		userId : req.user.id
	}, function(err, groceryList) {
		if (groceryList) {
			res.json(groceryList);
		} else {
			res.status(404).json({
				success: false,
				message: "No grocery list found"
			});
		}
	});

});


app.use('/api', apiRoutes);

app.get('*', function(req, res) {
	res.sendFile(path.resolve(publicPath, 'index.html'));
});

// And run the server
app.listen(port, function () {
  console.log('Server running on port ' + port);
});