var path = require('path');
var webpack = require('webpack');

require('dotenv').load();

module.exports = {
	entry: {
		app: [
			'./src/index.js'
		],
		vendor: [
			"!!script!jquery/dist/jquery.min.js",
			"!!script!foundation-sites/dist/foundation.min.js",
			"!!script!foundation-sites/dist/plugins/foundation.util.keyboard.js",
			"!!script!foundation-sites/dist/plugins/foundation.util.motion.js",
			"!!script!foundation-sites/dist/plugins/foundation.util.nest.js",
			"!!script!foundation-sites/dist/plugins/foundation.drilldown.js"
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
				loader: 'elm-webpack'
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
			}
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
	],

	devServer: {
		inline: true,
		stats: { colors : true },
		historyApiFallback: true
	},

};