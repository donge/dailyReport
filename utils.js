// Generated by CoffeeScript 1.10.0
(function() {
  var Response, dbconfig, redis;

  redis = require("redis");

  Response = require('./vo/Response').Response;

  dbconfig = require('./config').db;

  exports.authenticateUser = function(req, res) {
    var path, result;
    result = this.isLoginUser(req);
    path = "/login";
    if (this.isMobileClient(req)) {
      path = "/m/login";
    }
    if (!result) {
      res.redirect(path);
    }
    return result;
  };

  exports.isMobileClient = function(req) {
    var urlArray;
    urlArray = req.path.split("/");
    return urlArray[1] === "m";
  };

  exports.isLoginUser = function(req) {
    var ref;
    return ((ref = req.session) != null ? ref.userId : void 0) && true;
  };

  exports.authenticateAdmin = function(req, res) {
    var result;
    result = this.isAdmin(req);
    if (!result) {
      if (this.isLoginUser(req)) {
        res.redirect('/show');
      } else {
        res.redirect('/login');
      }
    }
    return result;
  };

  exports.isAdmin = function(req) {
    return this.isLoginUser(req) && req.session.isAdmin === 1;
  };

  exports.showDBError = function(callback, client, message) {
    if (client == null) {
      client = null;
    }
    if (message == null) {
      message = '数据库错误';
    }
    if (client) {
      client.quit();
    }
    return callback(new Response(0, message));
  };

  exports.createClient = function() {
    var client;
    client = redis.createClient(dbconfig.port, dbconfig.host);
    if (dbconfig.pass) {
      client.auth(dbconfig.pass, function(err) {
        if (err) {
          throw err;
        }
      });
    }
    client.on("error", function(err) {
      console.log(err);
      return client.end();
    });
    return client;
  };

}).call(this);
