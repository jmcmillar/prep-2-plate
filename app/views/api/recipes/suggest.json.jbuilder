json.suggestions do
  json.array! @facade.recipes do |recipe|
    json.id recipe.id
    json.name recipe.name
    json.imageUrl recipe.image.attached? ? rails_blob_url(recipe.image, host: request.host_with_port) : image_url("no-recipe-image.png", host: request.host_with_port)
  end
end
