image = new Image()
index = null
fadeInterval = null
progressInterval = null
msgDOM_Ary = ['.msg1', '.msg2', '.msg3']
fadeDOM_Ary = ['.temperature > .icon', '.humidity > .icon']
data = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
cAD = Settings.currentAnimateDuration #currentAnimateDuration
aD = Settings.animateDuration #animateDuration
bD = Settings.bufferDuration #bufferDuration
rD = (cAD - aD - bD) #restoreDuration


TweenLite.ticker.useRAF true
TweenLite.defaultEase = Power4.easeOut

progressAnimation = (duration = aD) ->
  TweenLite.to '.progressBar', duration, {
    opacity: 1
    height: 415
    ease: Power1.easeInOut
    onComplete: ->
      restoreProgressAnimation()
      slideAnimation()
  }

restoreProgressAnimation = ->
  TweenLite.to '.progressBar', rD, {
    opacity: 0.5
    height: 0
    onComplete: ->
      progressInterval = setInterval(calibrateProgressInterval, 10)
  }

slideAnimation = ->
  calibrateMsgData()
  TweenLite.fromTo msgDOM_Ary[0], 1, {opacity: 1, y: 0}, {opacity: 0, y: -200}
  TweenLite.fromTo msgDOM_Ary[1], 1, {y: 200}, {y: 0}
  TweenLite.fromTo msgDOM_Ary[2], 1, {opacity: 0, y: 400}, {opacity: 1, y: 200}
  calibrateMsgDOM()
  index++
  if index == data.length then index = 0

calibrateMsgData = ->
  offset_1 = index + 1
  if offset_1 == data.length then offset_1 = 0
  offset_2 = offset_1 + 1
  if offset_2 == data.length then offset_2 = 0
  $(msgDOM_Ary[0]).text(data[index])
  $(msgDOM_Ary[1]).text(data[offset_1])
  $(msgDOM_Ary[2]).text(data[offset_2])

calibrateProgressInterval = ->
  if moment().second() % cAD == 0
    clearInterval progressInterval
    progressAnimation()

calibrateMsgDOM = (status) ->
  if status == 1 || status == null
    [msgDOM_Ary[0], msgDOM_Ary[1], msgDOM_Ary[2]] = [msgDOM_Ary[1], msgDOM_Ary[2], msgDOM_Ary[0]]
  else if status == 2
    [msgDOM_Ary[0], msgDOM_Ary[1], msgDOM_Ary[2]] = [msgDOM_Ary[2], msgDOM_Ary[0], msgDOM_Ary[1]]

iconFadeAnimation = (duration = aD) ->
  TweenLite.to fadeDOM_Ary[0], duration, {opacity: 0.5, onComplete: fadeAnimation}

fadeAnimation = ->
  TweenLite.to $(fadeDOM_Ary[0]).parent(), rD, {opacity:0, onComplete: -> TweenLite.set fadeDOM_Ary[0], {opacity: 1}}
  TweenLite.to $(fadeDOM_Ary[1]).parent(), rD, {opacity:1, onComplete: -> fadeInterval = setInterval(calibrateFadeInterval, 10)}

calibrateFadeInterval = ->
  if moment().second() % cAD == 0
    clearInterval fadeInterval
    calibrateFadeDOM()
    iconFadeAnimation()

calibrateFadeDOM = ->
  [fadeDOM_Ary[0], fadeDOM_Ary[1]] = [fadeDOM_Ary[1], fadeDOM_Ary[0]]

initFadeAnimation = ->
  sec = moment().second()
  status = parseInt(sec / cAD) % 2
  currentSec = sec % cAD
  duration = aD - currentSec
  if status == 1 then calibrateFadeDOM()
  TweenLite.set $(fadeDOM_Ary[0]).parent(), {opacity: 1}
  TweenLite.set $(fadeDOM_Ary[1]).parent(), {opacity: 0}
  iconFadeAnimation(duration)

initSlideAnimation = ->
  min = moment().minutes()
  sec = moment().second()
  status = parseInt(sec / cAD) % 3
  currentSec = sec % cAD
  duration = aD - currentSec
  index = parseInt((min * 60 + sec) / cAD) % data.length
  calibrateMsgDOM(status)
  calibrateMsgData()
  TweenLite.set msgDOM_Ary[0], {opacity: 1, y: 0}
  TweenLite.set msgDOM_Ary[1], {opacity: 1, y: 200}
  TweenLite.set msgDOM_Ary[2], {opacity: 0, y: 400}
  progressAnimation(duration)

Template.home.onCreated ->
  Meteor.subscribe 'messages'
  Meteor.subscribe 'weatherdata', ->
    initWeatherIcon()
    updateBackground WeatherData.findOne().imageUrl
    WeatherData.find().observe
      changed: (newDoc, oldDoc) ->
        if newDoc.imageUrl != oldDoc.imageUrl then updateBackground newDoc.imageUrl
        if newDoc.weatherName != oldDoc.weatherName then updateWeatherIcon oldDoc.weatherName, newDoc.weatherName

Template.home.onRendered ->
  updateClock()
  initFadeAnimation()
  initSlideAnimation()

Template.home.helpers
  weatherData: ->
    return WeatherData.findOne()
  messages: ->
    return Messages.findOne()

initWeatherIcon = ->
  $('.weatherIcon').addClass "#{WeatherData.findOne().weatherName}"

updateBackground = (imageUrl) ->
  image.src = imageUrl
  image.onload = ->
    $('.preload').removeClass 'isloading'
    setTimeout ->
      $('.onloaded').css({'background-image': "url('#{image.src}')"})
      $('.preload').addClass 'isloading'
      setTimeout ->
        $('.preload').css({'background-image': "url('#{image.src}')"})
      , 4000
    , 4000

updateWeatherIcon = (oldDoc, newDoc) ->
  $('.weatherIcon').addClass 'updating'
  setTimeout ->
    $('.weatherIcon').removeClass "#{oldDoc}"
    $('.weatherIcon').addClass "#{newDoc}"
    $('.weatherIcon').removeClass 'updating'
  , 250

updateClock = ->
  now = moment()
  dateStr = now.format('L')
  weekdayStr = now.format('dddd')
  timeStr = now.format('a h:mm:ss')
  second = (now.seconds() + now.milliseconds() / 1000) * 6
  minute = now.minutes() * 6 + second / 60
  hour = ((now.hours() % 12) / 12) * 360 + 90 + minute / 12
  $('.hour').css('transform', "rotate(#{hour}deg)")
  $('.minute').css('transform', "rotate(#{minute}deg)")
  $('.second').css('transform', "rotate(#{second}deg)")
  $('.date').text(dateStr)
  $('.weekday').text(weekdayStr)
  $('.times').text(timeStr)
  setTimeout(updateClock, 40)
