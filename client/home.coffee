image = null

Template.home.onCreated ->
  $('body').attr('class', 'home')
  refreshWeatherData()
  Meteor.subscribe 'weatherdata', ->
    image = new Image()
    image.src = WeatherData.findOne()?.imageUrl
    image.onload = ->
      $('.onloaded').css({'background-image': "url('#{image.src}')"})
      $('.preload').addClass('onLoad')

Template.home.onRendered ->
  updateClock()
  setTimeout slideLeftAnimation.bind(null, $('.weather'), $('.humidity')), 10000
  setTimeout slideAnimation.bind(null, $('.msg1'), $('.msg3')), 10000
  setTimeout slideAnimation.bind(null, $('.msg2'), $('.msg4')), 15000

Template.home.helpers
  weatherData: ->
    return WeatherData.findOne()

refreshWeatherData = ->
  Meteor.call 'refreshWeatherData', (e) ->
    if e then console.log e

slideLeftAnimation = ($element_1, $element_2) ->
  $element_1.animate({
    opacity: 0
    transform: 'translateX(-1080px)'
  }, 1000, 'easeInOutQuint').animate {transform:'translateX(1080px)'}, 0

  $element_2.animate {
    opacity: 1
    transform: 'translateX(0px)'
  }, 1000, 'easeInOutQuint'

  setTimeout slideLeftAnimation.bind(null, $element_2, $element_1), 10000

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
  setTimeout slideAnimation.bind(null, $element_2, $element_1), 15000

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
  $('.date.text').text(dateStr)
  $('.weekday').text(weekdayStr)
  $('.times').text(timeStr)
  setTimeout(updateClock, 40)
