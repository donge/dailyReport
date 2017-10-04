/**
 * Module dependencies.
 */

var express = require('express')
  , http = require('http')
  , connect = require('connect')
  , routeProfile = require('./routes/routeProfile')
  , path = require('path')
  , redis = require("redis")
  , redisConfig = require('./config')
  , session = require('express-session')
  , redisStore = require('connect-redis')(session)
  , appport = redisConfig.app.port
  , sessiondbconfig = redisConfig.sessiondb
  , expressJWT = require('express-jwt')
  , jwt = require('jsonwebtoken');

var app = express();
var redisClient = redis.createClient(redisConfig.db.port,redisConfig.db.host);
redisClient.on("error", function(err) {
   console.log(err);
});

// all environments
app.set('port', appport || process.env.PORT || 4000);
app.set('views', __dirname + '/views');
app.set('view engine', 'hbs');
app.use(require('morgan')('dev'));
app.use(require('compression')());
app.use(require('body-parser')());
app.use(require('method-override')());
app.use(require('cookie-parser')());
app.use(session({ store: new redisStore({host:sessiondbconfig.host, port:sessiondbconfig.port, pass:sessiondbconfig.pass, db:sessiondbconfig.db, prefix:'sess', ttl:3600}), secret: 'iamwaltershe' }));
//app.use(app.router);

//allow cross domain
app.use(function(req, res, next) {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
  next();
});

//JWT auth
//app.use(expressJWT({secret: "copull"}).unless({path:["/login", "/", "/show", "/img", "/js"]}))

app.use(express.static(path.join(__dirname, 'public')));

// development only
if ('development' == app.get('env')) {
  app.use(require('errorhandler')());
}

routeProfile.createRoutes(app);

http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});
