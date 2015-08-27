if Meteor.isClient
  Router.route '/', ->
    @render 'home'

  Router.route '/msg', ->
    @render 'msg'

  Router.route '/editmsg', ->
    @render 'editmsg'
