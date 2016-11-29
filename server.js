var express = require('express');
var path = require('path');

var bodyParser = require('body-parser');
var jwt = require('jsonwebtoken');
var mongoose = require('mongoose');
var cors = require('cors');
var User = require('./app/models/user');
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
					id : pinterestUser.id
				}, function(err, user) {
					if (!err) {
						if (!user) {
							user = new User({
								id : pinterestUser.id,
								firstName : pinterestUser.first_name,
								lastName : pinterestUser.last_name,
							});

							user.save(function(err) {
								if (err) {
									res.json({ success : false, message: "There was an error ceating the User"});
								} else {
									var token = jwt.sign(user, app.get('secret'), {
										expiresIn: 60*40*24
									});

									res.json({
										success: true,
										message: "Authorization Successful",
										token: token 
									});
								}
								
							});

						} else {
							var jwtToken = jwt.sign(user, app.get('secret'), {
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

app.use('/api', apiRoutes);

app.get('*', function(req, res) {
	res.sendFile(path.resolve(publicPath, 'index.html'));
});

// And run the server
app.listen(port, function () {
  console.log('Server running on port ' + port);
});