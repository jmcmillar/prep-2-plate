json.shopping_list_items do
  json.array! @shopping_list do |shopping_list|
    json.id shopping_list.id
    json.name shopping_list.name
  end
end
