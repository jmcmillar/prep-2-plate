json.shopping_list_items do
  json.array! @shopping_list_items do |item|
    json.id item.id
    json.name item.name
  end
end
