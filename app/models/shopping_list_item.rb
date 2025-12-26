class ShoppingListItem < ApplicationRecord
  belongs_to :shopping_list, counter_cache: true, touch: true
  belongs_to :ingredient, optional: true

  validates :name, presence: true
  validates :packaging_form,
            inclusion: { in: Ingredient::PACKAGING_FORMS.keys.map(&:to_s), allow_nil: true, allow_blank: true }
  validates :preparation_style,
            inclusion: { in: Ingredient::PREPARATION_STYLES.keys.map(&:to_s), allow_nil: true, allow_blank: true }

  # Display name combines packaging + preparation + name for a natural reading format
  # Examples:
  #   "tomatoes" (name only)
  #   "Canned tomatoes" (packaging + name)
  #   "Diced tomatoes" (preparation + name)
  #   "Canned Diced tomatoes" (packaging + preparation + name)
  def display_name
    parts = []
    parts << Ingredient::PACKAGING_FORMS[packaging_form.to_sym] if packaging_form.present?
    parts << Ingredient::PREPARATION_STYLES[preparation_style.to_sym] if preparation_style.present?
    parts << name
    parts.join(" ")
  end
end
