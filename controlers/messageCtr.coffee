check = require('validator').check
messageModel = require('../models/messageModel')
userModel = require('../models/usersModel')
utils = require('../utils')
{Response} = require('../vo/Response')


exports.show = (req, res) ->
  return unless utils.authenticateUser(req,res)
  showPage(req, res, "message")

showPage = (req, res, pageTitle, data=null) ->
  userId = req.session.userId
  data = {} unless data
  # data["hasSubordinate"] = false
  data["isLoginUser"] = utils.isLoginUser(req)
  data["isAdmin"] = utils.isAdmin(req)
  messageModel.getMessages(userId, (response) ->
    res.render(pageTitle, data))


exports.send = (req, res) ->
  # console.log("trigger here")
  return unless utils.authenticateUser(req,res)
  senderId = req.session.userId
  receiver = req.body.receiver
  message = req.body.message

  try
    #console.log "#{content}, #{score}, #{content1}, #{content2}, #{content3}, #{content4}"
    check(receiver).notEmpty()
    check(message).notEmpty()
    check(senderId).notEmpty()
    messageModel.createMessage(senderId, receiver, message, (response)->
      res.send(response))
  catch error
    res.send(new Response(0,"短消息或者内容为空"))

exports.delMessage = (req, res) ->
  return unless utils.authenticateUser(req,res)
  userId = req.session.userId
  messageId =  req.body.messageId
  messageModel.deleteMessage(userId, messageId, (response)->
    res.send(response))


exports.getMessages = (req, res) ->
  return unless utils.authenticateUser(req,res)
  userId = req.body.userId
  #没有userId表示访问自己的日报
  userId = req.session.userId unless userId

  try
    messageModel.getMessages(userId, (response)->
      res.send(response))
  catch error
    res.send(new Response(0,"短消息获取错误"))