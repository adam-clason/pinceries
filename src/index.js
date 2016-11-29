'use strict';

// Require index.html so it gets copied to dist
require('./index.html');

require('./assets/images/groceries_bg.png');
require('./assets/images/pinterest_badge.png');

require('font-awesome-webpack');
require('./scss/style.scss');

var Elm = require('./Main.elm');
var mountNode = document.getElementById('main');

var flags = {
	jwt : localStorage.getItem('jwt') || "",
	accessToken : localStorage.getItem('access-token') || "",
	pinceriesApiBaseUrl: process.env.API_URL
};

var app = Elm.Main.embed(mountNode, flags);

app.ports.setAccessToken.subscribe(function (token) {
	localStorage.setItem('access-token', token);
});

app.ports.setJwt.subscribe(function (jwt) {
	localStorage.setItem('jwt', jwt);
});
