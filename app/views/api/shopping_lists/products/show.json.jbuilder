json.found true
json.product do
  json.id @product.id
  json.barcode @product.barcode
  json.name @product.name
  json.brand @product.brand
  json.ingredientId nil  # Future: Could implement ingredient matching
  json.packagingForm nil # Future: Could map from product.packaging
  json.preparationStyle nil
  json.displayName @product.name.downcase
end
