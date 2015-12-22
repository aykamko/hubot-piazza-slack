# Description
#   Unfurls Piazza post references (e.g. @1234)
#
# Configuration:
#   HUBOT_PIAZZA_CLASS_ID
#   HUBOT_PIAZZA_EMAIL
#   HUBOT_PIAZZA_PASS
#
# Commands:
#   @(\d+) - Match a Piazza post, unfurl post as bot reply
#
# Author:
#   aykamko

normalize = require('./lib/normalize')
Piazza = require('./lib/piazza')

module.exports = (robot) ->
  piazza = new Piazza(
    process.env.HUBOT_PIAZZA_CLASS_ID,
    process.env.HUBOT_PIAZZA_EMAIL,
    process.env.HUBOT_PIAZZA_PASS
  )

  constructStatusField = (res) ->
    statusText = []
    statusEmoji = ":white_check_mark:"
    if res.type == "note"
      statusEmoji = ":notebook:"
    else if res.no_answer > 0
      statusEmoji = ":x:"
      statusText.push("No answer.")
    else
      instructor_handled = false
      for node in res.children
        if node.type == 's_answer'
          pending = 'Student answered. '
          instructor_endorsed = false
          for e in node.tag_endorse
            if e.admin
              instructor_endorsed = true
              instructor_handled = true
              break
          pending += if instructor_endorsed then '[Endorsed]' else '[Unendorsed]'
          statusText.push(pending)
        else if node.type == 'i_answer'
          instructor_handled = true
          statusText.push('Instructor answered.')
      statusEmoji = if instructor_handled then ":white_check_mark:" else ":warning:"

    if res.no_answer_followup > 0
      statusEmoji = ":x:"
      statusText.unshift("#{res.no_answer_followup} unresolved
        #{if res.no_answer_followup > 1 then ' followups' else ' followup'}.")

    return {
      title: "Status #{statusEmoji}",
      value: statusText.join("\n"),
      short: true,
    }

  unfurlPost = (msg, postID) ->
    piazza.fetchPost(postID, (err, res) ->
      if err
        return

      postContent = normalize.markdown(res.history[0].content)
      msgAttachment = {
        color: "#3e7aab",  # piazza color
        title: normalize.unencode(res.history[0].subject),
        title_link: "https://piazza.com/class/#{piazza.classID}?cid=#{postID}",
        text: postContent.markdown,
        mrkdwn_in: ["text"],
        fields: [],
      }
      msgAttachment.image_url = postContent.firstImgSrc if postContent.firstImgSrc?
      msgAttachment.fields.push(constructStatusField(res))

      anons = new Set()
      authors = new Set()
      for entry in res.history
        authors.add(entry.uid)
        anons.add(entry.uid) if entry.anon != 'no'

      piazza.fetchUsers(Array.from(authors), (err, res) ->
        if err
          return

        msgAttachment.fields.push({
          title: if res.length > 1 then "Authors" else "Author",
          value: res.map((e) -> if anons.has(e.id) then "#{e.name} (anon)" else e.name).join("\n"),
          short: true,
        })

        # finally, Hubot posts unfurled piazza post
        robot.adapter.client._apiCall("chat.postMessage", {
          channel: msg.message.rawMessage.channel,
          text: "@#{postID} attached:",
          as_user: true,
          attachments: JSON.stringify([msgAttachment]),
        })
      )
    )

  robot.hear /piazza.com\/class\/([^\?]+)\?cid=(\d+)/i, (msg) ->
    classID = msg.match[1]
    return if piazza.classID != classID
    postID = msg.match[2]
    unfurlPost(msg, postID)

  robot.hear /@(\d+)/i, (msg) ->
    postID = msg.match[1]
    unfurlPost(msg, postID)
