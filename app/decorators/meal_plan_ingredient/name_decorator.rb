class MealPlanIngredient::NameDecorator < BaseDecorator
  def formatted_quantity
    [formatted_amount, unit_name].compact.join(" ")
  end

  def unit_name
    return unless @object.unit_name.present?
    return @object.unit_name if less_than_one?

    @object.unit_name.pluralize(quantity)
  end

  def less_than_one?
    quantity.zero? && formatted_amount.present?
  end
end
