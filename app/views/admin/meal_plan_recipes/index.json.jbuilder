json.array! @facade.calendar_events do |event|
  json.extract! event, :id, :title, :start
end
