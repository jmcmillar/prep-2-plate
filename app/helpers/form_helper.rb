module FormHelper
  def meal_planner_form_with(model: nil, scope: nil, url: nil, format: nil, **options, &block)
    options = options.merge(
      class: options[:class],
      builder: MealPlannerFormBuilder
    )

    tag.div do
      form_with(model: model, scope: scope, url: url, format: format, **options, &block)
    end
  end
end
