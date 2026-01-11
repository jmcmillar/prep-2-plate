json.array! @preferences do |preference|
  json.partial! "api/user_shopping_item_preferences/preference", preference: preference
end
