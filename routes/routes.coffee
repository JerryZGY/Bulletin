if Meteor.isClient
  Router.route '/', ->
    @render 'home'

  Router.route '/editmsg', ->
    @render 'editmsg'
