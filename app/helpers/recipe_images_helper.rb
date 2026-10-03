module RecipeImagesHelper
  # A recipe's uploaded image, else its import's linked image, else the
  # placeholder (pass placeholder: nil to get nil instead)
  def recipe_image_url(recipe, placeholder: "no-recipe-image.png")
    return rails_blob_url(recipe.image, host: request.host_with_port) if recipe.image.attached?
    return recipe.linked_image_url if recipe.linked_image_url.present?

    image_url(placeholder, host: request.host_with_port) if placeholder
  end
end
