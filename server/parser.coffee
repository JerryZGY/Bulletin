cheerio = Meteor.npmRequire 'cheerio'

Meteor.methods
  getTemperature: ->
    console.log ">>> parser getTemperature at #{this.connection?.clientAddress}"
    url = 'http://www.weatherlink.com/user/xistw/index.php?view=summary&headers=0'
    HTTP.get url, (err, res) ->
      console.log 'getting temperatureData'
      if err then return
      $ = cheerio.load(res.content)
      temperatureData = {
        outsideTemp: $("td[class='summary_data']:contains('Outside Temp')").next().text().replace(/\.\d C/,'')
        insideTemp: $("td[class='summary_data']:contains('Inside Temp')").next().text().replace(/\.\d C/,'')
        extraTemp: $("td[class='summary_data']:contains('Extra Temp 2')").next().text().replace(/\.\d C/,'')
      }
      _id = Temperature.findOne() || {}
      Temperature.update _id, {$set: temperatureData}, {upsert:true}
      console.log 'updated temperature collection'
