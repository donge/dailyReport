
# ViewModel---------------------------------------------------------------
ShowReportsViewModel = ->
  self = @
  self.reports = ko.observableArray([])
  self.summary = ko.observableArray([])
  self.reportNum = ko.observable(0)
  self.userId = ko.observable(null)
  self.pageNum = ko.computed(->
    pageNum = Math.ceil(self.reportNum() / NUMOFPAGE)
    pageNum = 1 if pageNum == 0
    pageNum)

  self.currentPage = ko.observable(1)
  self.editable = ko.observable(false)
  self.team = []

  self

# 初始化 ---------------------------------------------------------------

# 每页显示的日报条数
NUMOFPAGE = 10

setTeam = (users)->
  reportvm.team = users

getSummary = ()->

  for i in reportvm.team
    data = {page:reportvm.currentPage(), numOfPage:NUMOFPAGE, userId:i.id}
    ReportModel.getReports(data, (response)->
      return if response.state == 0
      for j in response.data
        reportvm.reports.push(j))


getReports = (userId=null)->
  data = {page:reportvm.currentPage(), numOfPage:NUMOFPAGE, userId:userId}
  ReportModel.getReports(data, (response)->
    return if response.state == 0
    console.log response.data
    reportvm.reports(response.data))

getReportNum = (userId=null)->
  ReportModel.getReportNum(userId, (response)->
    return if response.state == 0
    reportvm.reportNum(response.data))

window.initPageState = ->
  reportvm.reports([])
  reportvm.summary([])
  reportvm.reportNum(0)
  reportvm.userId(null)
  reportvm.editable(false)


reportvm = new ShowReportsViewModel()
ko.applyBindings(reportvm)

window.getReports = getReports
window.getSummary = getSummary
window.getReportNum = getReportNum
window.reportvm = reportvm
window.setTeam = setTeam

#翻页组件---------------------------------------
$("div.pagination").on("click", "button.pageNext", ->
  gotoPage(reportvm.currentPage()+1)
  false)

$("div.pagination").on("click", "button.pagePre", ->
  gotoPage(reportvm.currentPage()-1)
  false)

window.gotoPage = (page)->
  reportvm.currentPage(page)
  getReports(reportvm.userId())