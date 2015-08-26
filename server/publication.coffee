Meteor.publish 'weatherdata', ->
  WeatherData.find()

Meteor.publish 'messages', ->
  Messages.find()

Meteor.publish 'power', ->
  Power.find()
