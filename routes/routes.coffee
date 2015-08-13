if Meteor.isClient
  Router.route '/', ->
    @render 'home'
