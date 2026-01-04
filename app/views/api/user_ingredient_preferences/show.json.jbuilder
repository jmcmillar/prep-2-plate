json.id @preference.id
json.userId @preference.user_id
json.ingredient do
  json.id @preference.ingredient.id
  json.name @preference.ingredient.name
end
json.packagingForm @preference.packaging_form
json.preparationStyle @preference.preparation_style
json.preferredBrand @preference.preferred_brand
json.usageCount @preference.usage_count
json.lastUsedAt @preference.last_used_at
json.displayContext @preference.display_context
json.createdAt @preference.created_at
json.updatedAt @preference.updated_at
