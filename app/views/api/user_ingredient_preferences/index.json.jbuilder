json.array! @preferences do |preference|
  json.id preference.id
  json.user_id preference.user_id
  json.ingredient do
    json.id preference.ingredient.id
    json.name preference.ingredient.name
  end
  json.packaging_form preference.packaging_form
  json.preparation_style preference.preparation_style
  json.preferred_brand preference.preferred_brand
  json.usage_count preference.usage_count
  json.last_used_at preference.last_used_at
  json.display_context preference.display_context
  json.created_at preference.created_at
  json.updated_at preference.updated_at
end
