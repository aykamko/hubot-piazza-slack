request = require('request')

class Piazza
  constructor: (classID, email, pass) ->
    @classID = classID
    @jar = request.jar()
    @request = request.defaults({
      jar: @jar,
      json: false,
      url: 'https://piazza.com/logic/api',
    })

    @request.post({
      body: JSON.stringify({
        method: "user.login",
        params: {email: email, pass: pass},
      }),
    })

  fetchPost: (postID, callback) ->
    @request.post({
      body: JSON.stringify({
        method: "content.get",
        params: {cid: postID, nid: @classID},
      }),
    }, (err, _, body) ->
      debugger
      if err
        callback(err, null)
        return
      callback(err, JSON.parse(body).result)
    )

  fetchUsers: (userIDs, callback) ->
    @request.post({
      body: JSON.stringify({
        method: "network.get_users",
        params: {ids: userIDs, nid: @classID},
      }),
    }, (err, _, body) ->
      if err
        callback(err, null)
        return
      callback(err, JSON.parse(body).result)
    )

module.exports = Piazza
