var express = require('express');
var app = express();

var hbs = require('hbs');

app.set('view engine', 'html');
app.engine('html', hbs.__express);
app.use(express.static('public'));

app.get('/', function(req, res) {
	res.render('index');
});

app.listen(3000);