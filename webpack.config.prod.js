var path = require('path');
var webpack = require('webpack');

module.exports = {
	entry: {
		app: [
			'./src/index.js'
		],
		vendor: [
			"!!script!slideout/dist/slideout.min.js"
		]
	},

	externals: {
		jquery: "jQuery"
	},

	output: {
		path: path.resolve(__dirname + '/dist'),
		filename: '[name].js'

	},

	module: {
		loaders: [
			{
				test: /\.scss$/,
				loaders: [
					'style',
					'css',
					'sass',
				]
			},
			{
				test: /\.(html)$/,
				exclude: /node_modules/,
				loader: 'file?name=[name].[ext]',
			},
			{
				test: /\.elm$/,
				exclude: [/elm-stuff/, /node_modules/],
				loader: 'elm-webpack?pathToMake=node_modules/.bin/elm-make'
			},
			{
				test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
				loader: 'url-loader?limit=10000&mimetype=application/font-woff',
			},
			{
				test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
				loader: 'file-loader',
			},
			{
				test: /\.png$/,
				loader: 'file-loader?name=[name].[ext]',
			},

			/*{
				test: /\.js/,
				exclude: /node_modules/,
				loader: "script"

			}*/
		],

		noParse: /\.elm$/

	},

	sassLoader: {
		includePaths: [path.resolve(__dirname, "scss"), path.resolve(__dirname, "node_modules/foundation-sites/scss")]
	},

	plugins: [
		new webpack.DefinePlugin({
		  'process.env': {
		    'API_URL': JSON.stringify(process.env.API_URL),
		    'PINTEREST_REDIRECT_URL' : JSON.stringify(process.env.PINTEREST_REDIRECT_URL)
		  }
		})
	]

};