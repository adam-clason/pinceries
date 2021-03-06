'use strict';

// Require index.html so it gets copied to dist
require('./index.html');

require('./assets/images/groceries_bg.png');
require('./assets/images/pinterest_badge.png');

require('./assets/images/spin.svg');


require('font-awesome-webpack');
require('./scss/style.scss');

var Elm = require('./Main.elm');
var mountNode = document.getElementById('main');

var flags = {
	jwt : localStorage.getItem('jwt') || "",
	accessToken : localStorage.getItem('access-token') || "",
	pinceriesApiBaseUrl: process.env.API_URL,
	pinterestRedirectUrl: process.env.PINTEREST_REDIRECT_URL
};

var app = Elm.Main.embed(mountNode, flags);

app.ports.setAccessToken.subscribe(function (token) {
	localStorage.setItem('access-token', token);
});

app.ports.setJwt.subscribe(function (jwt) {
	localStorage.setItem('jwt', jwt);
});


(function() {
	var slideout = null;

	app.ports.initSlideoutPort.subscribe(function(val) {

		slideout = new Slideout({
			'panel' : document.getElementById('content'),
			'menu' : document.getElementById('grocery-list'),
			'side' : 'right',
			'padding' : 356
		}); 
		
		document.querySelector('.mini-list-link').addEventListener('click', function() {
		  slideout.toggle();
		});

		var fixed = document.querySelector('.top-bar');

		slideout.on('translate', function(translated) {
		  fixed.style.transform = 'translateX(' + (translated * -1) + 'px)';
		});

		slideout.on('beforeopen', function () {
		  fixed.style.transition = 'transform 300ms ease';
		  fixed.style.transform = 'translateX(-356px)';
		});

		slideout.on('beforeclose', function () {
		  fixed.style.transition = 'transform 300ms ease';
		  fixed.style.transform = 'translateX(0px)';
		});

		slideout.on('open', function () {
		  fixed.style.transition = '';
		});

		slideout.on('close', function () {
		  fixed.style.transition = '';
		});

	});

	app.ports.closeSlideoutPort.subscribe(function() {
		slideout && slideout.close();
	});

	app.ports.groceryListChangedPort.subscribe(function() {
		var elementCount = document.querySelector('.mini-list-link .count');

		elementCount.className += " added";

		setTimeout(function() {
			elementCount.className = elementCount.className.replace(/\sadded/, "");
		}, 1000);

	});

	var bottom = null;

	app.ports.pageLoaded.subscribe(function() {
		bottom = document.querySelector('.bottom');
	});

	window.onscroll = function() {

		if (bottom) {
			var elementTop = bottom.getBoundingClientRect().top,
				elementBottom = bottom.getBoundingClientRect().bottom;

			var isVisible = (elementTop >= 0 && elementBottom <= window.innerHeight);

			if (isVisible) {
				var cursor = bottom.dataset.nexturl; 
				
				bottom = null;

				app.ports.nextPage.send(cursor);

			}
		}
		
	};


})();

