image = new Image()
fadeTimeout = Settings.fadeTimeout
fadeDuration = Settings.fadeDuration

Template.home.onCreated ->
  TweenLite.ticker.useRAF false
  $('body').attr('class', 'home')
  Meteor.subscribe 'messages'
  Meteor.subscribe 'weatherdata', ->
    initWeatherIcon()
    WeatherData.find().observe
      changed: (newDoc, oldDoc) ->
        if newDoc.imageUrl != oldDoc.imageUrl
          updateBackground newDoc.imageUrl
        if newDoc.weatherName != oldDoc.weatherName
          updateWeatherIcon oldDoc.weatherName, newDoc.weatherName


Template.home.onRendered ->
  updateClock()
  updateAnimate()

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

initFadeAnimation = ($element_1, $element_2, sec) ->
  status = parseInt(sec / 10) % 2
  currentSec = parseInt(sec % 10)
  duration = (fadeTimeout / 1000) - currentSec
  animateOpacityPerFrame = 0.5 / (fadeTimeout / 1000)
  currentOpacity = duration * animateOpacityPerFrame
  if status == 1 then [$element_1, $element_2] = [$element_2, $element_1]
  $element_1.css {opacity: 1}
  $element_1.children('.icon').css {opacity: currentOpacity}
  $element_1.children('.icon').animate {opacity: 0.5}, duration * 1000
  $element_2.css {opacity: 0}
  $element_2.children('.icon').css {opacity: 0}

fadeAnimation = ($element_1, $element_2, sec) ->
  if sec
    status = parseInt(sec / 10) % 2
    if status == 1 then [$element_1, $element_2] = [$element_2, $element_1]
  setTimeout fadeAnimation.bind(null, $element_2, $element_1), fadeTimeout
  $element_1.finish().animate({
    opacity: 0
  }, fadeDuration, 'easeInOutQuint')

  $element_2.children('.icon').animate {opacity: 1}, fadeDuration
  $element_2.finish().animate {
    opacity: 1
  }, fadeDuration, 'easeInOutQuint', ->
    $element_2.children('.icon').animate {opacity: 0}, fadeTimeout

slideAnimation = ($element_1, $element_2) ->
  $element_1.animate({
    opacity: 0
    transform: 'translateY(250px)'
  }, 1000, 'easeInQuint', ->
    $element_2.animate({
      opacity: 1
      transform: 'translateY(0px)'
    }, 1000, 'easeOutQuint')
  )

updateAnimate = ->
  sec = moment().second()
  offset = ((fadeTimeout / 1000) - sec % 10) * 1000
  initFadeAnimation $('.temperature'), $('.humidity'), sec
  setTimeout fadeAnimation.bind(null, $('.temperature'), $('.humidity'), sec), offset

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
