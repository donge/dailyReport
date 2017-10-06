// Generated by CoffeeScript 1.10.0
(function() {
  var NUMOFPAGE, ShowReportsViewModel, getReportNum, getReports, getSummary, reportvm, setTeam;

  ShowReportsViewModel = function() {
    var self;
    self = this;
    self.reports = ko.observableArray([]);
    self.summary = ko.observableArray([]);
    self.reportNum = ko.observable(0);
    self.userId = ko.observable(null);
    self.pageNum = ko.computed(function() {
      var pageNum;
      pageNum = Math.ceil(self.reportNum() / NUMOFPAGE);
      if (pageNum === 0) {
        pageNum = 1;
      }
      return pageNum;
    });
    self.currentPage = ko.observable(1);
    self.editable = ko.observable(false);
    self.team = [];
    return self;
  };

  NUMOFPAGE = 10;

  setTeam = function(users) {
    return reportvm.team = users;
  };

  getSummary = function() {
    var data, i, k, len, ref, results;
    ref = reportvm.team;
    results = [];
    for (k = 0, len = ref.length; k < len; k++) {
      i = ref[k];
      data = {
        page: reportvm.currentPage(),
        numOfPage: NUMOFPAGE,
        userId: i.id
      };
      results.push(ReportModel.getReports(data, function(response) {
        var j, l, len1, ref1, results1;
        if (response.state === 0) {
          return;
        }
        ref1 = response.data;
        results1 = [];
        for (l = 0, len1 = ref1.length; l < len1; l++) {
          j = ref1[l];
          results1.push(reportvm.reports.push(j));
        }
        return results1;
      }));
    }
    return results;
  };

  getReports = function(userId) {
    var data;
    if (userId == null) {
      userId = null;
    }
    data = {
      page: reportvm.currentPage(),
      numOfPage: NUMOFPAGE,
      userId: userId
    };
    return ReportModel.getReports(data, function(response) {
      if (response.state === 0) {
        return;
      }
      console.log(response.data);
      return reportvm.reports(response.data);
    });
  };

  getReportNum = function(userId) {
    if (userId == null) {
      userId = null;
    }
    return ReportModel.getReportNum(userId, function(response) {
      if (response.state === 0) {
        return;
      }
      return reportvm.reportNum(response.data);
    });
  };

  window.initPageState = function() {
    reportvm.reports([]);
    reportvm.summary([]);
    reportvm.reportNum(0);
    reportvm.userId(null);
    return reportvm.editable(false);
  };

  reportvm = new ShowReportsViewModel();

  ko.applyBindings(reportvm);

  window.getReports = getReports;

  window.getSummary = getSummary;

  window.getReportNum = getReportNum;

  window.reportvm = reportvm;

  window.setTeam = setTeam;

  $("div.pagination").on("click", "button.pageNext", function() {
    gotoPage(reportvm.currentPage() + 1);
    return false;
  });

  $("div.pagination").on("click", "button.pagePre", function() {
    gotoPage(reportvm.currentPage() - 1);
    return false;
  });

  window.gotoPage = function(page) {
    reportvm.currentPage(page);
    return getReports(reportvm.userId());
  };

}).call(this);