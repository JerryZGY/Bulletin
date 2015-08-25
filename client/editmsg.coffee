messages = null
seq = 0

Template.editmsg.onRendered ->
  $('body').attr('class', 'editmsg')
  Meteor.subscribe 'messages', ->
    messages = Messages.findOne()
    if !messages
      messages = {
        title: ''
        msgs: []
      }
    else
      seq = messages.msgs.length
    console.log messages
    console.log 'seq', seq

Template.editmsg.helpers
  messages: ->
    return Messages.findOne()
  refreshTempAndHumiFreq: ->
    return Settings.refreshTempAndHumiFreq
  refreshWeatherFreq: ->
    return Settings.refreshWeatherFreq
  fadeAnimationTimeout: ->
    return Settings.fadeTimeout
  fadeAnimationDuration: ->
    return Settings.fadeDuration
  weatherData: ->
    return WeatherData.findOne()

Template.editmsg.events
  'click .remove': ->
    if seq != 0
      delete messages.msgs[seq]
      seq--
      messages.msgs.length = seq
      Meteor.call 'updateMsgData', messages

  'click .add': ->
    messages.msgs[seq] = {
      seq: seq
    }
    seq++
    Meteor.call 'updateMsgData', messages

  'click .apply': ->
    messages['title'] = $('#title').val()
    messages.msgs.forEach (item, i) ->
      item['content'] = $("#msg_#{i}").val()
    messages['modifiedAt'] = new Date()
    Meteor.call 'updateMsgData', messages
###
messages = {
  title: '追單'
  msg: [
    {
      seq: 0
      content: '韓國WEBPAT'
    }
    {
      seq: 1
      content: '台灣WEBPAT'
    }
  ]
  modifiedAt: 2015-08-25
}

###
