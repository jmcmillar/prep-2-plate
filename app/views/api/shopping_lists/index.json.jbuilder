json.shopping_lists do
  json.array! @shopping_lists do |shopping_list|
    json.id shopping_list.id
    json.name shopping_list.name
    json.current shopping_list.current
    json.itemCount shopping_list.shopping_list_items_count
  end
end
