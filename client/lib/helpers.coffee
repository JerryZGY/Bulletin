Template.registerHelper 'formatDate', (date, format) ->
  if !format or typeof format != 'string' then format = 'HH:mm:ss'
  moment(date).format(format)

Template.registerHelper 'plus', (a, b) ->
  a + b

Template.registerHelper 'triplePlus', (a, b, c) ->
  if a? && b? && c?
    return (Math.round((a + b + c) * 10) / 10) + 'kw'
  else
    return ''

Template.registerHelper 'formatFloat', (value) ->
  if value?
    (Math.round(value * 10) / 10) + 'kw'
  else
    return ''
