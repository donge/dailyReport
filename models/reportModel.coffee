
{Response} = require('../vo/Response')
userModel = require('./usersModel')
utils = require("../utils")

# 创建Report
exports.createReport = (userId, content, mark, content1, content2, content3, content4, dateStr, callback) ->
  client = utils.createClient()
  client.incr("next_report_id", (err, reportId)->
    return utils.showDBError(callback, client) if err
    score = getDateNumber(dateStr)
    client.zadd("userid:#{userId}:reportIds", score, reportId, (err, reply)->
      return utils.showDBError(callback, client) if err
      client.hmset("userid:#{userId}:reports", "#{reportId}:date", dateStr, "#{reportId}:content", content, "#{reportId}:mark", mark, "#{reportId}:content1", content1, "#{reportId}:content2", content2, "#{reportId}:content3", content3, "#{reportId}:content4", content4, "#{reportId}:time", Date(), (err, reply)->
        return utils.showDBError(callback, client) if err
        client.quit()
        callback(new Response(1,'success',reply)) )))

# 更新Report
exports.updateReport = (reportId, userId, content, mark, content1, content2, content3, content4, dateStr, callback) ->
  client = utils.createClient()
  console.log reportId, userId, content, mark, content1, content2, content3, content4, dateStr
  client.hmset("userid:#{userId}:reports", "#{reportId}:date", dateStr, "#{reportId}:content", content, "#{reportId}:mark", mark, "#{reportId}:content1", content1, "#{reportId}:content2", content2, "#{reportId}:content3", content3, "#{reportId}:content4", content4, "#{reportId}:time", Date(), (err, reply)->
    return utils.showDBError(callback, client) if err
    client.quit()
    callback(new Response(1,'success',reply)) )

#日期字符串变为数字，例如 “2013-4-27” 变为 20130427
getDateNumber = (dateStr)->
  [year, months, date] = dateStr.split("-")
  months = "0#{months}" if months.length == 1
  date = "0#{date}" if date.length == 1
  parseInt("#{year}#{months}#{date}")

exports.getReports = (userId, page, numOfPage, callback) ->
  client = utils.createClient()
  start =  numOfPage * (page-1)
  start = 0 if start < 0
  end = (numOfPage * page) - 1
  client.zrevrange("userid:#{userId}:reportIds", start, end, (err, reportIds)->
    return utils.showDBError(callback, client) if err
    return callback(new Response(1,'success',[])) if reportIds and reportIds.length == 0

    dateArgs = ["userid:#{userId}:reports"]
    timeArgs = ["userid:#{userId}:reports"]
    contentArgs = ["userid:#{userId}:reports"]
    markArgs = ["userid:#{userId}:reports"]
    content1Args = ["userid:#{userId}:reports"]
    content2Args = ["userid:#{userId}:reports"]
    content3Args = ["userid:#{userId}:reports"]
    content4Args = ["userid:#{userId}:reports"]
    for reportId in reportIds
      dateArgs.push("#{reportId}:date")
      timeArgs.push("#{reportId}:time")
      contentArgs.push("#{reportId}:content")
      markArgs.push("#{reportId}:mark")
      content1Args.push("#{reportId}:content1")
      content2Args.push("#{reportId}:content2")
      content3Args.push("#{reportId}:content3")
      content4Args.push("#{reportId}:content4")
    client.hmget(dateArgs, (err, dates)->
      return utils.showDBError(callback, client) if err
      client.hmget(timeArgs, (err, times)->
        return utils.showDBError(callback, client) if err
        client.hmget(contentArgs, (err, contents)->
          return utils.showDBError(callback, client) if err
          client.hmget(markArgs, (err, marks)->
            return utils.showDBError(callback, client) if err
            client.hmget(content1Args, (err, content1s)->
              return utils.showDBError(callback, client) if err
              client.hmget(content2Args, (err, content2s)->
                return utils.showDBError(callback, client) if err
                client.hmget(content3Args, (err, content3s)->
                  return utils.showDBError(callback, client) if err
                  client.hmget(content4Args, (err, content4s)->
                    return utils.showDBError(callback, client) if err
                    len = contents.length
                    response = []
                    for i in [0...len]
                      response.push({id:reportIds[i], date:dates[i], time:times[i], content:contents[i], mark:marks[i], content1:content1s[i], content2:content2s[i], content3:content3s[i], content4:content4s[i]})
                    client.quit()
                    callback(new Response(1,'success',response)) )))))))))

exports.getReportNum = (userId, callback) ->
  client = utils.createClient()
  client.zcount("userid:#{userId}:reportIds", "-inf", "+inf", (err, count)->
    return utils.showDBError(callback, client) if err
    client.quit()
    callback(new Response(1,'success',count)) )

exports.deleteReport = (userId, reportId, callback)->
  client = utils.createClient()
  client.zrem("userid:#{userId}:reportIds", reportId, (err, reply)->
    return utils.showDBError(callback, client) if err
    client.hdel("userid:#{userId}:reports", "#{reportId}:date", "#{reportId}:content", "#{reportId}:score", "#{reportId}:content1", "#{reportId}:content2", "#{reportId}:content3", "#{reportId}:content4", "#{reportId}:time",(err, reply)->
      return utils.showDBError(callback, client) if err
      client.quit()
      callback(new Response(1,'success',reply))))

exports.getSubordinateUserAndDepartment = (userId, callback)->
  client = utils.createClient()
  client.hgetall("users", (err, users)->
    return utils.showDBError(callback, client) if err
    [userObjs, userArray] = parseUsers(users)
    userTree = getDepartTreeData(userArray, {})
    subordinateIds = []
    children = []

    for user in userTree
      if user["id"] == userId
        children = user["children"]
        break

    getSubordinateIds = (children, subordinateIds)->
      for user in children
        subordinateIds.push(user["id"])
        getSubordinateIds(user["children"], subordinateIds) if user["children"]

    getSubordinateIds(children, subordinateIds)
    subordinateUsers = []

    for userId in subordinateIds
      subordinateUsers.push(userObjs[userId])

    client.hgetall("departments", (err, departments)->
      return utils.showDBError(callback, client) if err
      [departmentObjs, _] = parseDepartments(departments)
      subordinateDepartmentObjs = {}
      #console.log "subordinateUsers:"
      #console.log subordinateUsers
      for user in subordinateUsers
        if user["departmentId"]
          departmentId = user["departmentId"]
          subordinateDepartmentObjs[departmentId] = departmentObjs[departmentId]
      #console.log "subordinateDepartmentObjs:"
      #console.log subordinateDepartmentObjs
      subordinateDepartments = []
      for _, department of subordinateDepartmentObjs
        subordinateDepartments.push(department)
      #console.log "subordinateDepartments:"
      #console.log subordinateDepartments
      departmentTree = getDepartTreeData(subordinateDepartments, subordinateDepartmentObjs)

      getUserDepartmentTreeData = (departmentTree)->
        for department in departmentTree
          # 不是部门节点的跳过
          continue unless department["node"]
          departmentId = department["id"]
          department["children"] ?= []
          for user in subordinateUsers
            continue if user["departmentId"] != departmentId
            department["children"].push({id:user["id"],label:user["name"]})

          if department["children"]
            getUserDepartmentTreeData(department["children"])
      getUserDepartmentTreeData(departmentTree)
      console.log departmentTree
      client.quit()
      callback(new Response(1,'success',departmentTree))))

exports.getColleagueUserAndDepartment = (userId, callback)->
  client = utils.createClient()
  client.hgetall("users", (err, users)->
    return utils.showDBError(callback, client) if err
    [userObjs, userArray] = parseUsers(users)
    # h该函数输出数据 [{id:1, name:"walter",pid:"3", departmentId:"7"}]
    #console.log userObjs[userId]
    pid = userObjs[userId].pid if userObjs[userId].pid
    #console.log userArray

    getColleagueUsers = (pid, userArray)->
      colleagueArray = []
      for user in userArray
        if pid == user.pid
          tmp =
            id: "0"
            label: "null"
          tmp.id = user.id
          tmp.label = user.name
          colleagueArray.push(tmp)
      colleagueArray

    colleagueUsers = getColleagueUsers(pid, userArray)
    console.log colleagueUsers
    client.quit()
    callback(new Response(1,'success',colleagueUsers)))

# data 后台返回数据  	Object { 1:user_name="walter", 1:department_id="7", 1:superior_id:"3"}
 parseUsers = (data)->
  resultObj = {} #Object { 1:{id:1, name:"walter",pid:"3", departmentId:"7"}}
  for key, value of data
    childOfKey = key.split(":")
    userId = childOfKey[0]
    resultObj[userId] ?= {id: userId}
    if childOfKey[1] == "user_name"
      resultObj[userId]["name"] = value
    else if childOfKey[1] == "department_id"
      resultObj[userId]["departmentId"] = value
    else if childOfKey[1] == "superior_id"
      resultObj[userId]["pid"] = value

  result = []
  for key2, value2 of resultObj
    result.push(value2)

  # h该函数输出数据 [{id:1, name:"walter",pid:"3", departmentId:"7"}]
  [resultObj, result]

# data 后台返回数据  	Object { 1:name="PHP", 2:name="IOS", 3:name="p2", 3:pid="1"}
# 输出数据 Object { 1:{id:1, name:"PHP"}, 2:{id:2, name:"ios"},3:{id:3, name:"p2", pid:"1"}}
parseDepartments = (data)->
  resultObj = {}
  for key, value of data
    childOfKey = key.split(":")
    departmentId = childOfKey[0]
    resultObj[departmentId] ?= {id: departmentId}
    if childOfKey[1] == "name"
      resultObj[departmentId]["name"] = value
    else if childOfKey[1] == "pid"
      resultObj[departmentId]["pid"] = value

  result = []
  for key2, value2 of resultObj
    result.push(value2)

  # h该函数输出数据 [{id:1, name:"PHP"}, {id:2, name:"ios"},{id:3, name:"p2", pid:"1"}]
  [resultObj,result]

getDepartTreeData = (departs, allObjs)->
  #console.log departs
  #console.log allObjs
  treeData = []
  for value in departs
    rootnode = {label:value.name, id:value.id, node:1};
    treeData.push(rootnode) unless (value.pid and  allObjs[value.pid])

  findChidren = (node, departs)->
    for value in departs
      if value.pid == node.id
        node.children = [] unless node.children
        childNode = {label:value.name, id:value.id, node:1}
        node.children.push(childNode)
        findChidren(childNode, departs)

  for node in treeData
    findChidren(node, departs)

  treeData