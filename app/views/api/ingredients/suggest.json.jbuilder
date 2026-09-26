json.fragment @facade.fragment
json.suggestions do
  json.array! @facade.names do |name|
    json.name name
  end
end
