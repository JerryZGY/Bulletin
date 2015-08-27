messages = null
seq = 0

TweenLite.ticker.useRAF false

Template.editmsg.onRendered ->
  $('body').attr('class', 'editmsg')
  Meteor.subscribe 'weatherData'
  Meteor.subscribe 'power'
  Meteor.subscribe 'messages'

Template.editmsg.helpers
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
  refreshTempAndHumiFreq: ->
    return Settings.refreshTempAndHumiFreq
  refreshWeatherFreq: ->
    return Settings.refreshWeatherFreq
  refreshPowerFreq: ->
    return Settings.refreshPowerFreq
  currentAnimateDuration: ->
    return Settings.currentAnimateDuration
  animateDuration: ->
    return Settings.animateDuration
  bufferDuration: ->
    return Settings.bufferDuration
  weatherData: ->
    return WeatherData.findOne()
  power: ->
    return Power.findOne()

Template.editmsg.events
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
