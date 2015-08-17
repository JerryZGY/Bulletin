cheerio = Meteor.npmRequire 'cheerio'
async = Meteor.npmRequire 'async'

weatherText = {
  "0": "tornado" #龍選風
  "1": "tropical storm" #熱帶風暴
  "2": "hurricane" #颶風
  "3": "severe thunderstorms" #強雷陣雨
  "4": "thunderstorms" #雷陣雨
  "5": "mixed rain and snow" #雨雪
  "6": "mixed rain and sleet" #雨霰
  "7": "mixed snow and sleet" #雪霰
  "8": "freezing drizzle" #霜濛
  "9": "drizzle" #濛
  "10": "freezing rain" #霜雨
  "11": "showers" #陣雨
  "12": "showers" #陣雨
  "13": "snow flurries" #飄雪
  "14": "light snow showers" #陣雪
  "15": "blowing snow" #吹雪
  "16": "snow" #下雪
  "17": "hail" #冰雹
  "18": "sleet" #霰
  "19": "dust" #多塵
  "20": "foggy" #多霧
  "21": "haze" #陰霾
  "22": "smoky" #多煙
  "23": "blustery" #狂風
  "24": "windy" #風
  "25": "cold" #冷
  "26": "cloudy" #多雲
  "27": "mostly cloudy (night)" #晴時多雲(夜)
  "28": "mostly cloudy (day)" #晴時多雲(日)
  "29": "partly cloudy (night)" #晴時少雲(夜)
  "30": "partly cloudy (day)" #晴時少雲(日)
  "31": "clear (night)" #晴空(夜)
  "32": "sunny" #晴空(日)
  "33": "fair (night)" #晴朗(夜)
  "34": "fair (day)" #晴朗(日)
  "35": "mixed rain and hail" #冰雹雨
  "36": "hot" #炎熱
  "37": "isolated thunderstorms" #偶發雷雨
  "38": "scattered thunderstorms" #零星雷雨
  "39": "scattered thunderstorms" #零星雷雨
  "40": "scattered showers" #細雨
  "41": "heavy snow" #大雪
  "42": "scattered snow showers" #細雪雨
  "43": "heavy snow" #大雪
  "44": "partly cloudy" # 晴時少雲
  "45": "thundershowers" #雷陣雪
  "46": "snow showers" #細雪
  "47": "isolated thundershowers" #偶發雷雪
}

getTemperatureAndHumidity = (cb) ->

  parseHtmlToJSON = (html) ->

    getTextFromHtml = (text, pattern) ->
      $("td[class='summary_data']:contains(#{text})").next().text().replace pattern, ''

    $ = cheerio.load html
    return {
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
    when 26, 27, 28
      return 'cloudy'
    when 8, 9, 18, 19, 20, 21, 22, 23, 24, 25, 29, 30, 44
      return 'cloudy_day'
    when 31, 32, 33, 34, 36, 46
      return 'sunny'
    when 0, 1, 2, 3, 4, 37, 38, 39, 45, 47
      return 'storm'
    else
      return 'rainy'

getWeatherImageUrl = (weatherText, cb) ->
  apiKey = '4b6f5848ccc585ce0615730fe83dfdc7'
  groupID = '1463451@N25';
  photoSize = 'url_h' #url_h, url_o
  requestUrl = 'https://api.flickr.com/services/rest/?method=flickr.photos.search'
  requireArguments = "&api_key=#{apiKey}&group_id=#{groupID}&text=#{weatherText}&extras=#{photoSize}"
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

Meteor.methods
  refreshWeatherData: (cb) ->
    console.log ">>> refresh WeatherData at #{this.connection?.clientAddress}"
    async.parallel [
      getTemperatureAndHumidity
      getWeatherCode
    ], (e, r) ->
      if e then return cb e
      code = r[1]
      getWeatherImageUrl weatherText[code], (error, result) ->
        if error then cb error
        weatherData = {
          weatherName: parseCodeToName code
          imageUrl: result
          outsideTemp:  r[0]['outsideTemp']
          insideTemp:   r[0]['insideTemp']
          extraTemp:    r[0]['extraTemp']
          outsideHumi:  r[0]['outsideHumi']
          insideHumi:   r[0]['insideHumi']
          extraHumi:    r[0]['extraHumi']
        }
        _id = WeatherData.findOne()._id || {}
        WeatherData.update _id, {$set: weatherData}, {upsert:true}
        cb? null
  updateMsgData: (messages) ->
    _id = Messages.findOne()._id || {}
    Messages.update {}, {$set: messages}, {upsert:true}
    console.log ">>> message updated at #{this.connection?.clientAddress}"
