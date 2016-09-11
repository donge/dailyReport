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
