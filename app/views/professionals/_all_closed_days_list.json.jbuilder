json.all_closed_days @all_closed_days do |day|
  json.id day[:id]
  json.name day[:name]
  json.date day[:date].strftime('%d-%m-%Y')
end
