Template.editmsg.onRendered ->
  $('body').attr('class', 'editmsg')
  Meteor.subscribe 'messages'

Template.editmsg.helpers
  messages: ->
    return Messages.findOne()

Template.editmsg.events
  'blur .msg': ->
    try
      messages = {
        title: $('.title').val()
        msg_1: $('.msg_1').val()
        msg_2: $('.msg_2').val()
        msg_3: $('.msg_3').val()
        msg_4: $('.msg_4').val()
        modifiedAt: new Date()
      }
      Meteor.call 'updateMsgData', messages
    catch err
      console.log err
