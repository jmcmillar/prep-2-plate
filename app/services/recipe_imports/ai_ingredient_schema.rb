# JSON schema for structured-output ingredient parsing. Enums come from the
# Ingredient model so the model can only return values the app accepts.
class RecipeImports::AiIngredientSchema
  def self.schema
    {
      type: "object",
      properties: {
        ingredients: { type: "array", items: item_schema }
      },
      required: [ "ingredients" ],
      additionalProperties: false
    }
  end

  def self.item_schema
    {
      type: "object",
      properties: {
        line_index: { type: "integer" },
        quantity: { type: "string" },
        unit: { type: "string" },
        name: { type: "string" },
        notes: { type: "string" },
        packaging_form: { type: "string", enum: enum_values(Ingredient::PACKAGING_FORMS) },
        preparation_style: { type: "string", enum: enum_values(Ingredient::PREPARATION_STYLES) }
      },
      required: %w[line_index quantity unit name notes packaging_form preparation_style],
      additionalProperties: false
    }
  end

  def self.enum_values(forms)
    [ "", *forms.keys.map(&:to_s) ]
  end
end
