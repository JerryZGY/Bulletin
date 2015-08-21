Template.registerHelper 'formatDate', (date, format) ->
  if !format or typeof format != 'string' then format = 'HH:mm:ss'
  moment(date).format(format)