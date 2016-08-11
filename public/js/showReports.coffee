
getReports()
getReportNum()

confirm = (reportId)->
  $("#dialog-confirm").dialog({
    dialogClass: "no-close",
    resizable: false,
    height:160,
    modal: true,
    buttons: {
      "删除": ->
        deleteReport(reportId)
        $(@).dialog("close")
      Cancel: ->
        $(this).dialog("close")}})

$("#reportList").on("click", "p.delete", ->
  reportId = $(this).attr("reportId")
  confirm(reportId))

$("#reportList").on("click", "p.update", ->
  reportId = $(this).attr("reportId")
  #ReportModel.shouldShowMessage(false)


  # data = {date:dateStr, content:editor.getContent()}
  data = {id:reportId, date:$("#dateTxt").val(), content:$("#content").val(), score:$("#score").val(),
  content1:$("#content1").val(), content2:$("#content2").val(),
  content3:$("#content3").val(), content4:$("#content4").val()}
  console.log data

  ReportModel.updateReport(data, (response)->
    return if response.state == 0
    window.location.href = "/show"))


deleteReport = (reportId)->
  ReportModel.deleteReport({reportId:reportId}, (response)->
    return if response.state == 0

    reportvm.reportNum(reportvm.reportNum()-1)
    page = reportvm.currentPage()
    if (reportvm.reports().length == 1 &&  reportvm.currentPage() > 1)
      page = reportvm.currentPage() - 1
    gotoPage(page))
