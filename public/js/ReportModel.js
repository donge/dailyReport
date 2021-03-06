// Generated by CoffeeScript 1.10.0
(function() {
  var ReportModel;

  ReportModel = (function() {
    function ReportModel() {}

    ReportModel.createReport = function(data, callback) {
      return $.post("/write", data, function(response) {
        return callback(response);
      }, "json");
    };

    ReportModel.deleteReport = function(data, callback) {
      return $.post("/delete", data, function(response) {
        return callback(response);
      }, "json");
    };

    ReportModel.updateReport = function(data, callback) {
      return $.post("/update", data, function(response) {
        return callback(response);
      }, "json");
    };

    ReportModel.getReportNum = function(userId, callback) {
      return $.post("/getreportnum", {
        userId: userId
      }, function(response) {
        return callback(response);
      }, "json");
    };

    ReportModel.getSubordinateUserAndDepartment = function(callback) {
      return $.post("/getsubordinateuseranddepartment", function(response) {
        return callback(response);
      }, "json");
    };

    ReportModel.getColleagueUserAndDepartment = function(callback) {
      return $.post("/getcolleagueuseranddepartment", function(response) {
        return callback(response);
      }, "json");
    };

    ReportModel.getSubordinateUser = function(callback) {
      return $.post("/getsubordinateuser", function(response) {
        return callback(response);
      }, "json");
    };

    ReportModel.getReports = function(data, callback) {
      return $.post("/getreports", data, function(response) {
        return callback(response);
      }, "json");
    };

    return ReportModel;

  })();

  window.ReportModel = ReportModel;

}).call(this);
