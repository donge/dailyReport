validator = new Validator()
# 暂时不需要富文本编辑
# editor = UE.getEditor('content')

# ViewModel---------------------------------------------------------------
WriteReportViewModel = ->
  self = @
  self.dateTxt = ko.observable(null)
  self.validDateTxt = ko.computed(->
    dateStr = $.trim(self.dateTxt())
    try
      validator.check(dateStr).notEmpty()
      [year, months, date] = dateStr.split("-")
      #console.log "#{year}-#{months}-#{date}"
      validator.check(year).notNull().isNumeric().len(4,4)
      validator.check(months).notNull().isNumeric().len(1,2)
      validator.check(date).notNull().isNumeric().len(1,2)
      return true
    catch  error
      return false)

  self

# 初始化 ---------------------------------------------------------------
init = ->
  $("#dateTxt").datepicker();
  $("#dateTxt").datepicker("option", "dateFormat", "yy-mm-dd")

  reportvm = new WriteReportViewModel()
  ko.applyBindings(reportvm)

  getDateStr = (date)->
    today = new Date()
    year = date.getFullYear()
    month = date.getMonth() + 1
    date = date.getDate()
    return "#{year}-#{month}-#{date}"

  dateStr =  getDateStr(new Date())
  reportvm.dateTxt(dateStr)
  #console.log $("#dateTxt").datepicker("getDate")

  $("#reportSubmitBtn").click((event)->
    return unless reportvm.validDateTxt()
    dateStr = getDateStr($("#dateTxt").datepicker("getDate"))
    # data = {date:dateStr, content:editor.getContent()}
    data = {date:dateStr, deal:$("#deal").val(), marks:$("#marks").val(), back_marks:$("#back_marks").val(),
    content1:$("#content1").val(), content3:$("#content3").val(), content4:$("#content4").val(),
    cc:$("#cc").val(), input:$("#input").val(), follow:$("#follow").val(),meet:$("#meet").val()}
    console.log data

    ReportModel.createReport(data, (response)->
      return if response.state == 0
      window.location.href = "/show"))

init()