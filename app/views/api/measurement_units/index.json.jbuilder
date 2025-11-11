json.measurementUnits do
  json.array! @measurement_units do |measurement_unit|
    json.id measurement_unit.id
    json.name measurement_unit.name
  end
end
