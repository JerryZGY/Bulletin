Template.msg.onRendered ->
  $('body').attr('class', 'msg')
  Meteor.subscribe 'messages'

Template.msg.helpers
  title: ->
    return Messages.findOne()?.title
  msgs: ->
    if data = Messages.findOne()?.msgs
      data = data.map (v, i) ->
        return { msg: v, seq: i }
      total = 0
      if data.length < 4
        total = 4
      else
        total = data.length + 1
      i = data.length
      while i < total
        data.push { msg: '', seq: i }
        i++
    return data

Template.msg.events
  'blur input': ->
    Meteor.call 'updateMsgData', {title: $('#title').val()}

  'blur textarea': ->
    msgs = []
    $('.row > .msg').each ->
      value = $(this).val()
      if value != '' then msgs.push value
    i = msgs.length - 1
    while i < 4
      i++
      $("##{i}").val('')
    Meteor.call 'updateMsgData', {msgs: msgs}
