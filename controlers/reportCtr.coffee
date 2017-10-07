crypto = require('crypto');
check = require('validator').check
reportModel = require('../models/reportModel')
userModel = require('../models/usersModel')
utils = require('../utils')
{Response} = require('../vo/Response')

exports.index = (req, res) ->
  return unless utils.authenticateUser(req,res)
  res.redirect("/show")

exports.writeIndex = (req, res) ->
  return unless utils.authenticateUser(req,res)
  showPage(req, res, "write")

exports.settingMobile = (req, res) ->
  return unless utils.authenticateUser(req,res)
  res.render("mobile/settings", {'title':"设置", layout:"mobile/layout.hbs"})

exports.writeIndexMobile = (req, res) ->
  return unless utils.authenticateUser(req,res)
  showPage(req, res, "mobile/write", {'title':"写日报", layout:"mobile/layout.hbs", "currentDateStr": getDateStr(new Date())})

getDateStr = (date)->
  today = new Date()
  year = date.getFullYear()
  month = date.getMonth() + 1
  month = "0" + month if month < 10
  date = date.getDate()
  date = "0" + date if date < 10
  return "#{year}-#{month}-#{date}"

exports.write = (req, res) ->
  console.log("trigger here")
  return unless utils.authenticateUser(req,res)
  userId = req.session.userId
  dateStr = req.body.date
  marks = req.body.marks
  back_marks = req.body.back_marks
  content1 = req.body.content1
  content3 = req.body.content3
  content4 = req.body.content4
  cc = req.body.cc
  input = req.body.input
  follow = req.body.follow
  meet = req.body.meet

  try
    console.log "#{marks}, #{back_marks},#{content1}, #{content3}, #{content4}, #{cc}, #{input}, #{follow}, #{meet}"
    check(dateStr).notEmpty()
    check(marks).notEmpty()
    check(back_marks).notEmpty()
    check(content1).notEmpty()
    check(content3).notEmpty()
    check(cc).notEmpty()
    check(input).notEmpty()
    check(follow).notEmpty()
    check(meet).notEmpty()

    [year, months, date] = dateStr.split("-")
    #console.log "#{year}-#{months}-#{date}"
    #console.log "*******************************"
    #console.log "#{content}, #{marks}, #{content1}, #{content2}, #{content3}, #{content4}"
    check(year).notNull().isNumeric().len(4,4)
    check(months).notNull().isNumeric().len(1,2)
    check(date).notNull().isNumeric().len(1,2)
    reportModel.createReport(userId, marks, back_marks, content1, content3, content4, cc, input, follow, meet, dateStr, (response)->
    #reportModel.createReport(userId, content, dateStr, (response)->
      res.send(response))
  catch error
    res.send(new Response(0,"日期格式不正确或者内容为空"))

exports.update = (req, res) ->
  return unless utils.authenticateUser(req,res)
  userId = req.session.userId
  reportId = req.body.id
  dateStr = req.body.date
  marks = req.body.marks
  back_marks = req.body.back_marks
  back_marks = req.body.back_marks
  content1 = req.body.content1
  content3 = req.body.content3
  content4 = req.body.content4
  cc = req.body.cc
  input = req.body.input
  follow = req.body.follow
  meet = req.body.meet

  try
    #console.log "#{content}, #{marks}, #{content1}, #{content2}, #{content3}, #{content4}"
    check(dateStr).notEmpty()
    check(marks).notEmpty()
    check(back_marks).notEmpty()
    check(content1).notEmpty()
    check(content3).notEmpty()
    check(cc).notEmpty()
    check(input).notEmpty()
    check(follow).notEmpty()
    check(meet).notEmpty()
    [year, months, date] = dateStr.split("-")
    #console.log "#{year}-#{months}-#{date}"
    #console.log "*******************************"
    #console.log "#{content}, #{marks}, #{content1}, #{content2}, #{content3}, #{content4}"
    check(year).notNull().isNumeric().len(4,4)
    check(months).notNull().isNumeric().len(1,2)
    check(date).notNull().isNumeric().len(1,2)
    reportModel.updateReport(reportId, userId, marks, back_marks, content1, content3, content4, cc, input, follow, meet, dateStr, (response)->
    #reportModel.createReport(userId, content, dateStr, (response)->
      res.send(response))
  catch error
    res.send(new Response(0,"日期格式不正确或者内容为空"))

exports.showIndex = (req, res) ->
  return unless utils.authenticateUser(req,res)
  showPage(req, res, "show")

exports.showSummary = (req, res) ->
  return unless utils.authenticateUser(req,res)
  showPage(req, res, "show_summary")

exports.showIndexMobile = (req, res) ->
  return unless utils.authenticateUser(req,res)
  showPage(req, res, "mobile/show", {'title':"我的日报", layout:"mobile/layout.hbs"})

showPage = (req, res, pageTitle, data=null) ->
  userId = req.session.userId
  data = {} unless data
  data["hasSubordinate"] = false
  data["isLoginUser"] = utils.isLoginUser(req)
  data["isAdmin"] = utils.isAdmin(req)
  userModel.hasSubordinate(userId, (result)->
    if result
      data["hasSubordinate"] = true
    res.render(pageTitle, data))

exports.showsubordinateIndex = (req, res) ->
  return unless utils.authenticateUser(req,res)
  userId = req.session.userId
  userModel.hasSubordinate(userId, (result)->
    if result
      res.render("showsubordinate", {hasSubordinate:true, isLoginUser:utils.isLoginUser(req),isAdmin:utils.isAdmin(req)})
    else
      res.send(new Response(0,'您还没有下属，不需要访问该页面')))


exports.showteamIndex = (req, res) ->
  return unless utils.authenticateUser(req,res)
  userId = req.session.userId
  userModel.hasSubordinate(userId, (result)->
    if result
      res.render("show_team", {hasSubordinate:true, isLoginUser:utils.isLoginUser(req),isAdmin:utils.isAdmin(req)})
    else
      res.send(new Response(0,'您还没有下属，不需要访问该页面')))


exports.showcolleagueIndex = (req, res) ->
  return unless utils.authenticateUser(req,res)
  userId = req.session.userId
  res.render("showcolleague", {hasSubordinate:true, isLoginUser:utils.isLoginUser(req),isAdmin:utils.isAdmin(req)})

exports.subordinateIndexMobile = (req, res) ->
  return unless utils.authenticateUser(req,res)
  userId = req.session.userId
  userModel.hasSubordinate(userId, (result)->
    if result
      res.render("mobile/showsubordinate", {title:"下属日报", layout:"mobile/layout.hbs", hasSubordinate:true, isLoginUser:utils.isLoginUser(req),isAdmin:utils.isAdmin(req)})
    else
      res.send(new Response(0,'您还没有下属，不需要访问该页面')))


exports.getReports = (req, res) ->
  # !!! 删除登录，为了测试 ！！！
  return unless utils.authenticateUser(req,res)

  #第几页
  page =  req.body.page
  userId = req.body.userId
  #没有userId表示访问自己的日报
  userId = req.session.userId unless userId

  #每页显示条数
  numOfPage =  req.body.numOfPage
  try
    check(page).isNumeric().min(1)
    check(page).isNumeric().min(1)
    reportModel.getReports(userId, page, numOfPage, (response)->
      res.send(response))
  catch error
    res.send(new Response(0,"页数和每页显示条数为非负数"))

exports.getSummary = (req, res) ->
  startDate = req.body.start_date
  endDate = req.body.end_date
  #没有userId表示访问自己的日报

  #每页显示条数
  numOfPage =  req.body.numOfPage
  try
    reportModel.getSummary(startDate, endDate, (response)->
      res.send(response))
  catch error
    res.send(new Response(0,"页数和每页显示条数为非负数"))


exports.getReportNum = (req, res) ->
  return unless utils.authenticateUser(req,res)
  userId = req.body.userId
  #没有userId表示访问自己的日报
  userId = req.session.userId unless userId

  reportModel.getReportNum(userId, (response)->
    res.send(response))

exports.delete = (req, res) ->
  return unless utils.authenticateUser(req,res)
  userId = req.session.userId
  reportId =  req.body.reportId
  reportModel.deleteReport(userId, reportId, (response)->
    res.send(response))


exports.getSubordinateUserAndDepartment = (req, res) ->
  return unless utils.authenticateUser(req,res)
  userId = req.session.userId
  reportModel.getSubordinateUserAndDepartment(userId, (response)->
    res.send(response))

exports.getSubordinateUser = (req, res) ->
  return unless utils.authenticateUser(req,res)
  userId = req.session.userId
  reportModel.getSubordinateUser(userId, (response)->
    res.send(response))

exports.getColleagueUserAndDepartment = (req, res) ->
  return unless utils.authenticateUser(req,res)
  userId = req.session.userId
  reportModel.getColleagueUserAndDepartment(userId, (response)->
    res.send(response))