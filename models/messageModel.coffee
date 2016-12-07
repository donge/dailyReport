{Response} = require('../vo/Response')
utils = require("../utils")

exports.createMessage = (senderId, receiverId, messageTxt, callback) ->
  client = utils.createClient()
  client.incr("next_message_id", (err, messageId)->
    return utils.showDBError(callback, client) if err
    score = messageId
    client.zadd("userid:#{receiverId}:messageIds", score, messageId, (err, reply)->
      return utils.showDBError(callback, client) if err
      client.hmset("userid:#{receiverId}:messages", "#{messageId}:sender", senderId, "#{messageId}:message", messageTxt, "#{messageId}:time", Date(), (err, reply)->
        return utils.showDBError(callback, client) if err
        client.quit()
        callback(new Response(1,'success',reply)))))

exports.deleteMessage = (receiverId, messageId, callback)->
  client = utils.createClient()
  client.zrem("userid:#{receiverId}:messageIds", messageId, (err, reply)->
    return utils.showDBError(callback, client) if err
    client.hdel("userid:#{receiverId}:messages", "#{messageId}:sender", "#{messageId}:message", "#{messageId}:time",(err, reply)->
      return utils.showDBError(callback, client) if err
      client.quit()
      callback(new Response(1,'success',reply))))

exports.getMessages = (receiverId, callback) ->
  userId = receiverId
  client = utils.createClient()
  client.zrevrange("userid:#{userId}:messageIds", 0, -1, (err, messageIds)->
    return utils.showDBError(callback, client) if err
    return callback(new Response(1,'success',[])) if messageIds and messageIds.length == 0

    messageArgs = ["userid:#{userId}:messages"]
    timeArgs = ["userid:#{userId}:messages"]
    senderArgs = ["userid:#{userId}:messages"]

    for messageId in messageIds
      messageArgs.push("#{messageId}:message")
      timeArgs.push("#{messageId}:time")
      senderArgs.push("#{messageId}:sender")

    client.hmget(messageArgs, (err, messages)->
      return utils.showDBError(callback, client) if err
      client.hmget(timeArgs, (err, times)->
        return utils.showDBError(callback, client) if err
        client.hmget(senderArgs, (err, senders)->
          return utils.showDBError(callback, client) if err

          len = messages.length
          response = []
          for i in [0...len]
            response.push({id:messageIds[i], time:times[i], sender:senders[i], message:messages[i]})

          client.quit()
          callback(new Response(1,'success',response))))))

# 获取自己团队最上级管理员列表
exports.getMsgSupervisor = (receiverId, callback) ->
  userId = receiverId
  client = utils.createClient()
  client.hgetall("users", (err, users)->
    return utils.showDBError(callback, client) if err
    [userObjs, userArray] = parseUsers(users)

    # TODO: hardcode 获取特定高级主管，如果没有，就是系统管理员
    superId = isSupervisor(userObjs, userId, "李凤春")
    if superId == 1
      superId = isSupervisor(userObjs, userId, "厉少华")
      if superId == 1
        superId = isSupervisor(userObjs, userId, "潘高煊总")
    console.log("isSupervisor " + superId)
    client.quit()
    callback(new Response(1,'success', userObjs[superId])))

isSupervisor = (userDict, userId, superName) ->
  pid = userId
  #console.log("super find")
  for level in [1..4] # 4 最大级别
    #console.log(userDict[pid]["name"])
    if pid
      if userDict[pid]["name"]
        if userDict[pid]["name"] == superName
          #console.log(userDict[pid]["name"])
          return pid # 上级pid
    if userDict[pid]["pid"]
      pid = userDict[pid]["pid"]
  return 1 # 管理员pid

 #data 后台返回数据  	Object { 1:user_name="walter", 1:department_id="7", 1:superior_id:"3"}
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