# message model层，处理数据调用和解析 ---------------------------------------------------------------
class MessageModel

  @createMessage: (data, callback)->
    $.post("/send", data, (response)->
      callback(response)
    , "json")

  @delMessage: (data, callback)->
    $.post("/delmessage", data, (response)->
      callback(response)
    , "json")


  @getReportNum: (userId, callback)->
    $.post("/getreportnum", {userId:userId}, (response)->
      callback(response)
    , "json")

  @getSubordinateUserAndDepartment: (callback)->
    $.post("/getsubordinateuseranddepartment",(response)->
      callback(response)
    , "json")

  @getColleagueUserAndDepartment: (callback)->
    $.post("/getcolleagueuseranddepartment",(response)->
      callback(response)
    , "json")

  #返回数据格式为[ { date: '2013-4-30',cotent: '<p><br /></p>4.30 reports' },{ date: '2013-4-30',content: '4.30 reports' }]
  @getMessages: (data, callback)->
    $.post("/getmessages", data, (response)->
      callback(response)
    , "json")

window.MessageModel = MessageModel