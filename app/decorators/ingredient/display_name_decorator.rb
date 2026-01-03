class Ingredient::DisplayNameDecorator < BaseDecorator
  def display_name
    parts = []
    parts << Ingredient::PACKAGING_FORMS[packaging_form.to_sym] if packaging_form.present?
    parts << Ingredient::PREPARATION_STYLES[preparation_style.to_sym] if preparation_style.present?
    parts << name
    parts.join(" ").downcase
  end
end
