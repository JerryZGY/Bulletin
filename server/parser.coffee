cheerio = Meteor.npmRequire 'cheerio'
async = Meteor.npmRequire 'async'

weatherText = {
  0:  {text: "tornado", current: "龍選風"}
  1:  {text: "tropical storm", current: "熱帶風暴"}
  2:  {text: "hurricane", current: "颶風"}
  3:  {text: "severe thunderstorms", current: "強雷陣雨"}
  4:  {text: "thunderstorms", current: "雷陣雨"}
  5:  {text: "mixed rain and snow", current: "雨雪"}
  6:  {text: "mixed rain and sleet", current: "雨霰"}
  7:  {text: "mixed snow and sleet", current: "雪霰"}
  8:  {text: "freezing drizzle", current: "霜濛"}
  9:  {text: "drizzle", current: "濛"}
  10: {text: "freezing rain", current: "霜雨"}
  11: {text: "showers", current: "陣雨"}
  12: {text: "showers", current: "陣雨"}
  13: {text: "snow flurries", current: "飄雪"}
  14: {text: "light snow showers", current: "陣雪"}
  15: {text: "blowing snow", current: "吹雪"}
  16: {text: "snow", current: "下雪"}
  17: {text: "hail", current: "冰雹"}
  18: {text: "sleet", current: "霰"}
  19: {text: "dust", current: "多塵"}
  20: {text: "foggy", current: "多霧"}
  21: {text: "haze", current: "陰霾"}
  22: {text: "smoky", current: "多煙"}
  23: {text: "blustery", current: "狂風"}
  24: {text: "windy", current: "風"}
  25: {text: "cold", current: "冷"}
  26: {text: "cloudy", current: "多雲"}
  27: {text: "mostly cloudy (night)", current: "晴時多雲"}
  28: {text: "mostly cloudy (day)", current: "晴時多雲"}
  29: {text: "partly cloudy (night)", current: "晴時少雲"}
  30: {text: "partly cloudy (day)", current: "晴時少雲"}
  31: {text: "clear (night)", current: "晴空"}
  32: {text: "sunny", current: "晴空"}
  33: {text: "fair (night)", current: "晴朗"}
  34: {text: "fair (day)", current: "晴朗"}
  35: {text: "mixed rain and hail", current: "冰雹雨"}
  36: {text: "hot", current: "炎熱"}
  37: {text: "isolated thunderstorms", current: "偶發雷雨"}
  38: {text: "scattered thunderstorms", current: "零星雷雨"}
  39: {text: "scattered thunderstorms", current: "零星雷雨"}
  40: {text: "scattered showers", current: "細雨"}
  41: {text: "heavy snow", current: "大雪"}
  42: {text: "scattered snow showers", current: "細雪雨"}
  43: {text: "heavy snow", current: "大雪"}
  44: {text: "partly cloudy", current: "晴時少雲"}
  45: {text: "thundershowers", current: "雷陣雪"}
  46: {text: "snow showers", current: "細雪"}
  47: {text: "isolated thundershowers", current: "偶發雷雪"}
}

getTemperatureAndHumidity = (cb) ->

  parseHtmlToJSON = (html) ->

    getTextFromHtml = (text, pattern) ->
      $("td[class='summary_data']:contains(#{text})").next().text().replace pattern, ''

    $ = cheerio.load html
    return {
      highest:      $("td[class='summary_data']:contains('Outside Temp')").next().next().text().replace /\.\d C/, ''
      lowest:       $("td[class='summary_data']:contains('Outside Temp')").next().next().next().next().text().replace /\.\d C/, ''
      outsideTemp:  getTextFromHtml 'Outside Temp', /\.\d C/
      insideTemp:   getTextFromHtml 'Inside Temp', /\.\d C/
      extraTemp:    getTextFromHtml 'Extra Temp 2', /\.\d C/
      outsideHumi:  getTextFromHtml 'Outside Humidity', '%'
      insideHumi:   getTextFromHtml 'Inside Humidity', '%'
      extraHumi:    getTextFromHtml 'Extra Humidity 2', '%'
    }

  url = 'http://www.weatherlink.com/user/xistw/index.php?view=summary&headers=0'
  HTTP.get url, (e, r) ->
    if e then return cb e
    data = parseHtmlToJSON r.content
    cb null, data

getWeatherCode = (cb) ->
  url = "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20%3D%202304389%20and%20u%20%3D%20'c'&format=json"
  HTTP.get url, (e, r) ->
    if e then return cb e
    json = JSON.parse r.content
    code = parseInt json.query.results.channel.item.condition.code
    cb null, code

parseCodeToName = (code) ->
  switch code
    when 8, 9, 18, 20, 21, 26
      return 'cloudy'
    when 19, 22, 23, 24, 25, 27, 28, 29, 30, 44
      return 'cloudy_day'
    when 31, 32, 33, 34, 36, 46
      return 'sunny'
    when 0, 1, 2, 3, 4, 37, 38, 39, 45, 47
      return 'storm'
    else
      return 'rainy'

getWeatherImageUrl = (text, cb) ->
  apiKey = '4b6f5848ccc585ce0615730fe83dfdc7'
  groupID = '1463451@N25';
  photoSize = 'url_h' #url_h, url_o
  requestUrl = 'https://api.flickr.com/services/rest/?method=flickr.photos.search'
  requireArguments = "&api_key=#{apiKey}&group_id=#{groupID}&text=#{text}&extras=#{photoSize}"
  extraArguments = '&content_type=1&media=photo&format=json&nojsoncallback=1'

  parsePhotosDataToUrl = (data) ->
    data = data.filter (item) ->
      typeof item[photoSize] == 'string'
    selectIndex = Math.floor (Math.random() * data.length)
    url = data[selectIndex][photoSize]
    return url

  HTTP.get requestUrl + requireArguments + extraArguments, (e, r) ->
    if e then return cb e
    data = (JSON.parse r.content).photos.photo
    imageUrl = parsePhotosDataToUrl data
    cb null, imageUrl

updateRefreshCron = ->
  SyncedCron.stop()
  name = 'refreshWeather'
  SyncedCron.add
    name: name
    schedule: (parser) ->
      console.log "*** schedule: #{name} is scheduled"
      parser.text Settings.refreshWeatherFreq
    job: ->
      console.log "*** schedule: #{name} is triggered"
      Meteor.call 'refreshWeather', (e) ->
        if e then console.log e

  name = 'refreshTempAndHumi'
  SyncedCron.add
    name: name
    schedule: (parser) ->
      console.log "*** schedule: #{name} is scheduled"
      parser.text Settings.refreshTempAndHumiFreq
    job: ->
      console.log "*** schedule: #{name} is triggered"
      Meteor.call 'refreshTempAndHumi', (e) ->
        if e then console.log e
  SyncedCron.start()

Meteor.methods
  refreshTempAndHumi: (cb) ->
    console.log ">>> call refreshTempAndHumi"
    getTemperatureAndHumidity (e, r) ->
      if e then return cb e
      weatherData = {
        highest:      r['highest']
        lowest:       r['lowest']
        outsideTemp:  r['outsideTemp']
        insideTemp:   r['insideTemp']
        extraTemp:    r['extraTemp']
        outsideHumi:  r['outsideHumi']
        insideHumi:   r['insideHumi']
        extraHumi:    r['extraHumi']
      }
      _id = WeatherData.findOne()._id || {}
      WeatherData.update _id, {$set: weatherData}, {upsert:true}
      cb? null

  refreshWeather: (cb) ->
    console.log ">>> call refreshWeather"
    getWeatherCode (e, r) ->
      if e then return cb e
      code = r
      getWeatherImageUrl weatherText[code].text, (error, result) ->
        if error then cb error
        weatherData = {
          weatherName: parseCodeToName code
          weatherCurrentName: weatherText[code].current
          imageUrl: result
        }
        _id = WeatherData.findOne()._id || {}
        WeatherData.update _id, {$set: weatherData}, {upsert:true}
        cb? null

  updateMsgData: (messages) ->
    _id = Messages.findOne()._id || {}
    Messages.update {}, {$set: messages}, {upsert:true}
    console.log ">>> message updated at #{this.connection?.clientAddress}"

  name: (name = 'cloudy') ->
    #cloudy, cloudy_day, rainy, strom, sunny
    _id = WeatherData.findOne()._id || {}
    WeatherData.update _id, {$set: {weatherName: name}}, {upsert:true}
    return "changed to #{name}"

Meteor.startup ->
  updateRefreshCron()
