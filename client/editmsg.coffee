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

Template.editmsg.helpers
  messages: ->
    return Messages.findOne()
  content: ->
    msgs = {}
    if Messages.findOne()
      msgs = Messages.findOne().msgs.map (v, i)->
        return {
          msg: v
          seq: i
        }
    return msgs
  refreshTempAndHumiFreq: ->
    return Settings.refreshTempAndHumiFreq
  refreshWeatherFreq: ->
    return Settings.refreshWeatherFreq
  currentAnimateDuration: ->
    return Settings.currentAnimateDuration
  animateDuration: ->
    return Settings.animateDuration
  bufferDuration: ->
    return Settings.bufferDuration
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
    messages.msgs[seq] = ''
    seq++
    Meteor.call 'updateMsgData', messages

  'click .apply': ->
    messages['title'] = $('#title').val()
    messages.msgs = messages.msgs.map (v, i) ->
      return $("#msg_#{i}").val()
    messages['modifiedAt'] = new Date()
    Meteor.call 'updateMsgData', messages
