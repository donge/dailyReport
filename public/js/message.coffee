
# ViewModel---------------------------------------------------------------
ShowMessagesViewModel = ->
  self = @
  self.messages = ko.observableArray([])
  self.userId = ko.observable(null)

  self

# 初始化 ---------------------------------------------------------------

# 每页显示的日报条数
NUMOFPAGE = 10

getMessages = (userId=null)->
  data = {userId:userId}
  MessageModel.getMessages(data, (response)->
    return if response.state == 0
    messageVM.messages(response.data))


window.initPageState = ->
  messageVM.messages([])
  messageVM.userId(null)

messageVM = new ShowMessagesViewModel()
ko.applyBindings(messageVM)

window.gets = getMessages
window.messageVM = messageVM

getMessages()

#翻页组件---------------------------------------
$("div.pagination").on("click", "button.pageNext", ->
  gotoPage(reportvm.currentPage()+1)
  false)

$("div.pagination").on("click", "button.pagePre", ->
  gotoPage(reportvm.currentPage()-1)
  false)

$("#messageSendBtn").click((event)->
  receiverId = 1
  if ($("#receiver").val() == "李风春")
    receiverId = 1
  data = {receiver:receiverId, message:$("#messageTxt").val()}
  # console.log data

  MessageModel.createMessage(data, (response)->
    return if response.state == 0
    window.location.href = "/message"))

confirm = (reportId)->
  $("#dialog-confirm").dialog({
    dialogClass: "no-close",
    resizable: false,
    height:160,
    modal: true,
    buttons: {
      "删除": ->
        deleteMessage(reportId)
        $(@).dialog("close")
      Cancel: ->
        $(this).dialog("close")}})


$("#messageList").on("click", "p.delete", ->
  console.log("del message")
  messageId = $(this).attr("messageId")
  confirm(messageId))



window.gotoPage = (page)->
  getMessages(messageVM.userId())


deleteMessage = (messageId)->
  MessageModel.delMessage({messageId:messageId}, (response)->
    return if response.state == 0
    window.location.href = "/message")
