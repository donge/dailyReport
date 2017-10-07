// Generated by CoffeeScript 1.10.0
(function() {
  var WriteReportViewModel, init, validator;

  validator = new Validator();

  WriteReportViewModel = function() {
    var self;
    self = this;
    self.dateTxt = ko.observable(null);
    self.validDateTxt = ko.computed(function() {
      var date, dateStr, error, error1, months, ref, year;
      dateStr = $.trim(self.dateTxt());
      try {
        validator.check(dateStr).notEmpty();
        ref = dateStr.split("-"), year = ref[0], months = ref[1], date = ref[2];
        validator.check(year).notNull().isNumeric().len(4, 4);
        validator.check(months).notNull().isNumeric().len(1, 2);
        validator.check(date).notNull().isNumeric().len(1, 2);
        return true;
      } catch (error1) {
        error = error1;
        return false;
      }
    });
    return self;
  };

  init = function() {
    var dateStr, getDateStr, reportvm;
    $("#dateTxt").datepicker();
    $("#dateTxt").datepicker("option", "dateFormat", "yy-mm-dd");
    reportvm = new WriteReportViewModel();
    ko.applyBindings(reportvm);
    getDateStr = function(date) {
      var month, today, year;
      today = new Date();
      year = date.getFullYear();
      month = date.getMonth() + 1;
      date = date.getDate();
      return year + "-" + month + "-" + date;
    };
    dateStr = getDateStr(new Date());
    reportvm.dateTxt(dateStr);
    return $("#reportSubmitBtn").click(function(event) {
      var data;
      if (!reportvm.validDateTxt()) {
        return;
      }
      dateStr = getDateStr($("#dateTxt").datepicker("getDate"));
      data = {
        date: dateStr,
        marks: $("#marks").val(),
        back_marks: $("#back_marks").val(),
        content1: $("#content1").val(),
        content3: $("#content3").val(),
        content4: $("#content4").val(),
        cc: $("#cc").val(),
        input: $("#input").val(),
        follow: $("#follow").val(),
        meet: $("#meet").val()
      };
      console.log(data);
      return ReportModel.createReport(data, function(response) {
        if (response.state === 0) {
          return;
        }
        return window.location.href = "/show";
      });
    });
  };

  init();

}).call(this);
