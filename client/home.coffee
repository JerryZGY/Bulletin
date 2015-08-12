dura = 1500
timeout = 5000

Template.home.onRendered ->
  deWeatherQueue()
  setBackground('rain')
  setOutsideTemp()
  updateClock()

deWeatherQueue = ->
  $('.times').animate({opacity: 0}, {
    duration: dura
    queue: 'weatherQueue'
    complete: ->
      $('.temp').animate {opacity: 1}, dura
  }).dequeue('weatherQueue')

  $('.clock').animate({opacity: 0}, {
    duration: dura
    queue: 'weatherQueue'
    complete: ->
      $('.weather').animate {opacity: 1}, dura
      setTimeout deClockQueue, timeout
  }).dequeue('weatherQueue')

deClockQueue = ->
  $('.temp').animate({opacity: 0}, {
    duration: dura
    queue: 'clockQueue'
    complete: ->
      $('.times').animate {opacity: 1}, dura
  }).dequeue('clockQueue')

  $('.weather').animate({opacity: 0}, {
    duration: dura
    queue: 'clockQueue'
    complete: ->
      $('.clock').animate {opacity: 1}, dura
      setTimeout deWeatherQueue, timeout
  }).dequeue('clockQueue')

setOutsideTemp = ->
  $.ajax {
    url: "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20%3D%202304389%20and%20u%20%3D%20'c'&format=json&callback=?"
    dataType: 'json'
    success: (data) ->
      $('#outsideTemp').text data.query.results.channel.item.condition.temp
  }

updateClock = ->
  now = moment()
  dateStr = now.format('L')
  weekdayStr = now.format('dd')
  timeStr = now.format('hh:mm:ss')
  second = (now.seconds() + now.milliseconds() / 1000) * 6
  minute = now.minutes() * 6 + second / 60
  hour = ((now.hours() % 12) / 12) * 360 + 90 + minute / 12
  $('.hour').css('transform', "rotate(#{hour}deg)")
  $('.minute').css('transform', "rotate(#{minute}deg)")
  $('.second').css('transform', "rotate(#{second}deg)")
  $('.date').text("#{dateStr}(#{weekdayStr})")
  $('.times').text(timeStr)
  setTimeout(updateClock, 40)

setBackground = (weather = 'sunny') ->
  apiKey = '4b6f5848ccc585ce0615730fe83dfdc7'
  groupID = '1463451@N25';
  photoSize = 'url_h' #url_h, url_o
  requestUrl = 'https://api.flickr.com/services/rest/?method=flickr.photos.search'
  requireArguments = "&api_key=#{apiKey}&group_id=#{groupID}&text=#{weather}&extras=#{photoSize}"
  extraArguments = '&content_type=1&media=photo&format=json'
  photoUrl = ''
  $.ajax {
    url: requestUrl + requireArguments + extraArguments
    dataType: 'jsonp'
    jsonp: 'jsoncallback'
    success: (data) ->
      photosData = $.grep data.photos.photo, (photo) ->
        typeof photo[photoSize] == 'string'
      photosData = $.map photosData, (photo) ->
        photo[photoSize]
      selectIndex = Math.floor (Math.random() * photosData.length)
      photoUrl = photosData[selectIndex]
      image = new Image()
      image.src = photoUrl
      image.onload = ->
        $('.bg').css 'background-image', "url(#{photoUrl})"
        $('.bg').addClass 'start'

  }
